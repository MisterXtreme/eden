Eden Mod API
============
The Eden mod API provides a single function to get information about the current subgame version. The mod itself is only intended for the purpose of registering required features.

`eden.get_version()`

* Returns a table containing fields `version`, `type` (release type), `core` (corresponding Minetest core version), `core_type` (correspending release type of Minetest core).