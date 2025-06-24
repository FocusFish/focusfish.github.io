# Assets

Up-to-date asset information is vital to the function of UVMS. To facilitate
adding & updating asset information there are several interfaces available, see
[asset reference](../reference/asset.md) section.

Historically there have been many attempts at a unique vessel ID, with one of
the main problems being adoption. Vessels typically have many different types
of IDs connected to them. A vessel within the EU might have a national ID, CFR,
MMSI, IRCS, and more.

In order to determine if a new asset should be created or not UVMS uses the
following list of IDs to identify a vessel:

1. IMO
1. CFR
1. National ID
1. IRCS
1. MMSI

Note that roughly speaking, the three first IDs (IMO, CFR, and National ID) are
tied to the vessel while the two last ones (IRCS and MMSI) are tied to the
owner / sending equipment.

## Deeper dive into IDs

Even with this list of IDs there are quite some nuances that need to be taken
into account. Attaching more details to each ID on its lifetime starts to give
a clearer picture of problems that might arise when adding / updating assets.

1. IMO: unique - follows vessel
1. CFR: unique - follows vessel while inside EU
1. National ID: unique per country - follows vessel inside country
1. IRCS: should be unique (per country) but reuse has happened in the past,
   might not follow vessel when sold
1. MMSI: unique (per country), follows the owner and not the vessel, but might
   be taken over by new owner

The reason for including IRCS and MMSI in this list is that they are used for
finding assets that might have been added through e.g. an AIS static report, or
finding existing assets in the AIS movement flow (only IRCS and MMSI are sent).

UVMS versions prior to 4.6.0 had all of the IDs set as globally unique which
meant that importing/exporting/renting vessels became troublesome. Later
versions (>=4.6.0) loosened those restrictions somewhat. For example, National
ID and IRCS are now unique per country and not globally unique. In addition,
UVMS now allow several inactive vessels with the same IRCS/MMSI, but only one
active to account for the "reuse has happened in the past even though it's not
supposed to happen" scenarios.

## Flows

Having looked at which IDs have been chosen for UVMS a natural follow up
question is

> When is an asset created / updated?

There are several asset flows within UVMS, chief of which is a "national
source" of asset data, but also incoming positions and static reports. The
"national source" should be considered the main data source and all other flows
are there to shore up any missed data.

??? warning "National Source module"

    Due to its nature, a "national source" component is not supplied by UVMS
    since it directly fetches data from an internal vessel source that differs in
    all installations. Typically that functionality is implemented as a module that
    utilizes the asset JMS interface (`jms/queue/UVMSAssetEvent`).

A simplified version of the default create / update flow is as follows:

``` mermaid
---
title: The "national source" create/update asset flow
---
sequenceDiagram
    autonumber
    participant ns as "National source" module
    participant a as Asset module

    ns->>a: Upsert asset
    a->>Database: Look for existing assets
    Database-->>a: No asset found<br>or existing asset found
    a->>Database: Create new asset<br>or update existing asset
    Database-->>a: Created / Updated
    a-->>ns: Ok
```

Note that step 2 tries to use all of the IDs listed above, specifically
utilizing the default ID set in the upsert asset request. Typically that would
be set to CFR for within the EU. This create / update flow covers most cases,
however there are edge cases that needs to be taken into account, see section
[Scenarios](#scenarios) for such edge cases.

## Scenarios

The following subchapters detail what happens in a few select scenarios.

### AIS positions before "national source" sync

> What happens if a vessel starts sending AIS positions before the
> national source has been updated or synced?

In UVMS the following happens:

``` mermaid
---
title: AIS movement flow
---
sequenceDiagram
    autonumber
    AIS module->>Movement module: Incoming AIS position
    Movement module->>Asset module: Collect Asset &<br>Mobile Terminal
    Asset module->>Database: Create new unknown asset since<br>MMSI/IRCS doesn't exist in database
    Database-->>Asset module: Created
    Asset module-->>Movement module: Return created asset
    Movement module->>Movement module: Continue processing<br>incoming movement
```

In step 3 UVMS creates a new "unknown" asset that does not contain much
information since all the AIS position carries is MMSI/IRCS. Neither of which
is present in the database yet. When next an update from the "national source"
comes into the system there are three separate pieces of data that need to be
reconciled; the incoming data, the "old" asset, and the unknown asset that was
created in the step above.

``` mermaid
---
title: Update from "national source" with already present unknown asset from AIS flow
---
sequenceDiagram
    autonumber
    participant ns as "National source" module
    participant a as Asset module
    participant d as Database
    participant m as Movement module

    ns->>a: Upsert asset
    a->>d: Look for existing assets
    d-->>a: Multiple existing assets found
    a->>d: Merge all asset information into one entry
    d-->>a: Updated
    a->>m: Asset merged event
    m->>d: Remap movements and movement connect
    d-->>m: Updated
    m-->>a: Ok
    a-->>ns: Ok
```

Another way to look at it is from the data point of view. The following
flowchart shows what it looks like after the "Unknown" asset was created and
just before any processing of the "national source" update has happened.

``` mermaid
---
title: Update from "national source" with already present unknown asset from AIS flow
---
flowchart TD
    classDef default fill:#e9eded84,stroke:#38664184,stroke-width:1px,text-align: left;
    classDef dotted stroke-width:1px,stroke-dasharray: 5 5;
    classDef green fill:#83994f;

    subgraph outcome [After]
        inc[" "]:::dotted --> DB[(Asset)]
        DB -.-> A["`Asset
        {
        cfr: SWE00...
        imo: 992...
        nationalId: 193...
        name: **abc**
        ircs: **SFB-9876**
        mmsi: **2561234**
        active: **true**
        ...
        }`"]:::green
        DB -.-> B[" "]:::dotted
    end

    subgraph before [Before]
        sinc["`Asset
        {
        cfr: SWE00...
        imo: 992...
        nationalId: 193...
        name: **abc**
        ircs: **SFB-9876**
        mmsi: **2561234**
        active: **true**
        ...
        }`"]:::green --> sDB[(Asset)]

        sDB -.-> sB["`Asset
        {
        cfr: SWE00...
        imo: 992...
        nationalId: 193...
        name: **abc**
        ircs: **SFB-1234**
        mmsi: **2560987**
        active: **true**
        ...
        }`"]
        sDB -.-> sA["`Asset
        {
        cfr: null
        imo: null
        nationalId: null
        name: **Unknown-1234**
        ircs: **SFB-9876**
        mmsi: **2561234**
        active: **true**
        ...
        }`"]

    end
```

As can be seen in the flowchart above, the two assets already in the database
don't have any IDs in common. It's not until the "national source" update comes
in that a conflict arises that needs sorting out. As mentioned already, the
conflict is solved by merging the three entities and remapping any positions
tied to the "Unknown" asset to the asset from "national source".

### Sale from EU country to non-EU country and back

> What happens when a vessel is sold from a EU country to a non-EU country?
> What happens if it's then sold back to the origin country?

When a vessel is sold outside of the EU, only IMO is kept (if it has one). From
UVMS point of view, if the vessel does not have IMO then there are no in common
IDs that can be used in order to maintain history across borders. In essence,
once exported, the vessel is a completely new vessel and the old one should be
set to inactive at the "national source" that is then synced to UVMS.

If the vessel is then sold back to the origin country, it might retain the old
IDs from before the export. At least CFR (and IMO) should be the same as before
the export. That means, the old entry from before the export can now be updated
and history for the vessel continues.

### Seasonal rental from other EU country

> What happens if a vessel is rented out to another company in another EU
> country?

When staying within the EU, CFR is kept which means that updates to e.g. IRCS
and MMSI is done directly to the original vessel (as well as changing the
nation that it's registered under).

If updates to the "national source" is slow the [AIS position
scenario](#ais-positions-before-national-source-sync) might occur.

### VMS positions and IDs

> How are IDs related to VMS positions?

VMS positions do not directly interact with the above mentioned IDs. Instead VMS
positions map positions to assets through DNID and member number, i.e. channel
-> mobile terminal -> asset. This means that, for positions to be assigned to
the correct asset, mobile terminal and channels need to be correctly
configured for the assets.

