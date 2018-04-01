local CATEGORY_NAME = "Privileges"

function ulx.grantprivilege(calling_ply, target_ply, privilege)
    local value = ULib.playerPrivileges[privilege]

    if not value then
        ULib.tsayError(calling_ply, "Invalid privilege specified", true)

        return
    end

    if target_ply:HasPrivilege(value) then
        ULib.tsayError(calling_ply, "Target already has this privilege", true)

        return
    end

    target_ply:GrantPrivilege(value)
    ulx.fancyLogAdmin(calling_ply, "#A granted privilege #s to ##T", privilege, target_ply)
end

local grantprivileges = ulx.command(CATEGORY_NAME, "ulx grantprivilege", ulx.grantprivilege, "!gp")

grantprivileges:addParam{
    type = ULib.cmds.PlayerArg
}

grantprivileges:addParam{
    type = ULib.cmds.StringArg,
    completes = table.GetKeys(ULib.playerPrivileges),
    hint = "privilege",
    ULib.cmds.restrictToCompletes
}

grantprivileges:defaultAccess(ULib.ACCESS_SUPERADMIN)
grantprivileges:help("Grant a privilege to a player.")

function ulx.revokeprivilege(calling_ply, target_ply, privilege)
    local value = ULib.playerPrivileges[privilege]

    if not value then
        ULib.tsayError(calling_ply, "Invalid privilege specified", true)

        return
    end

    if not target_ply:HasPrivilege(value) then
        ULib.tsayError(calling_ply, "Target does not has this privilege", true)

        return
    end

    target_ply:RevokePrivilege(value)
    ulx.fancyLogAdmin(calling_ply, "#A revoked privilege #s from #T", privilege, target_ply)
end

local revokeprivileges = ulx.command(CATEGORY_NAME, "ulx revokeprivilege", ulx.revokeprivilege, "!rp")

revokeprivileges:addParam{
    type = ULib.cmds.PlayerArg
}

revokeprivileges:addParam{
    type = ULib.cmds.StringArg,
    completes = table.GetKeys(ULib.playerPrivileges),
    hint = "privilege",
    ULib.cmds.restrictToCompletes
}

revokeprivileges:defaultAccess(ULib.ACCESS_SUPERADMIN)
revokeprivileges:help("Revoke a privilege from a player.")

function ulx.checkprivilege(calling_ply, target_ply)
    local privilegeHas = {}

    for k, v in pairs(ULib.playerPrivileges) do
        if target_ply:HasPrivilege(v) then
            table.insert(privilegeHas, k)
        end
    end

    if #privilegeHas == 0 then
        ULib.tsayError(calling_ply, "Target has no privileges", true)

        return
    end

    ulx.fancyLog({calling_ply}, "#P has privileges #s", target_ply, table.concat(privilegeHas, ", "))
end

local checkprivileges = ulx.command(CATEGORY_NAME, "ulx checkprivileges", ulx.checkprivilege, "!cp")

checkprivileges:addParam{
    type = ULib.cmds.PlayerArg
}

checkprivileges:defaultAccess(ULib.ACCESS_SUPERADMIN)
checkprivileges:help("Check what privileges a player has.")

---------------------------------------------------------
function ulx.grantprivilegeid(calling_ply, steamid, privilege)
    steamid = steamid:upper()

    if not ULib.isValidSteamID(steamid) then
        ULib.tsayError(calling_ply, "Invalid steamid.")

        return
    end

    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamid then
            ulx.grantPrivilege(calling_ply, v, privilege)

            return
        end
    end

    local value = ULib.playerPrivileges[privilege]

    if not value then
        ULib.tsayError(calling_ply, "Invalid privilege specified", true)

        return
    end

    if ULib.hasPrivilege(steamid, value) then
        ULib.tsayError(calling_ply, "Target already has this privilege", true)

        return
    end

    ULib.grantPrivilege(steamid, value)
    ulx.fancyLogAdmin(calling_ply, "#A granted #s <#s>", steamid, privilege)
end

local grantprivilegesid = ulx.command(CATEGORY_NAME, "ulx grantprivilegeid", ulx.grantprivilegeid, "!gpi")

grantprivilegesid:addParam{
    type = ULib.cmds.StringArg,
    hint = "privilege"
}

grantprivilegesid:addParam{
    type = ULib.cmds.StringArg,
    completes = table.GetKeys(ULib.playerPrivileges),
    hint = "privilege",
    ULib.cmds.restrictToCompletes
}

grantprivilegesid:defaultAccess(ULib.ACCESS_SUPERADMIN)
grantprivilegesid:help("Grant a privilege to a player.")

function ulx.revokeprivilegeid(calling_ply, steamid, privilege)
    steamid = steamid:upper()

    if not ULib.isValidSteamID(steamid) then
        ULib.tsayError(calling_ply, "Invalid steamid.")

        return
    end

    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamid then
            ulx.revokePrivilege(calling_ply, v, privilege)

            return
        end
    end

    local value = ULib.playerPrivileges[privilege]

    if not value then
        ULib.tsayError(calling_ply, "Invalid privilege specified", true)

        return
    end

    if not ULib.hasPrivilege(steamid, value) then
        ULib.tsayError(calling_ply, "Target does not has this privilege", true)

        return
    end

    ULib.revokePrivilege(steamid, value)
    ulx.fancyLogAdmin(calling_ply, "#A revoked <#s> from #s", privilege, steamid)
end

local revokeprivilegesid = ulx.command(CATEGORY_NAME, "ulx revokeprivilegeid", ulx.revokeprivilegeid, "!rpi")

revokeprivilegesid:addParam{
    type = ULib.cmds.StringArg,
    hint = "steamid"
}

revokeprivilegesid:addParam{
    type = ULib.cmds.StringArg,
    completes = table.GetKeys(ULib.playerPrivileges),
    hint = "privilege",
    ULib.cmds.restrictToCompletes
}

revokeprivilegesid:defaultAccess(ULib.ACCESS_SUPERADMIN)
revokeprivilegesid:help("Revoke a privilege from a player.")

function ulx.checkprivilegeid(calling_ply, steamid)
    steamid = steamid:upper()

    if not ULib.isValidSteamID(steamid) then
        ULib.tsayError(calling_ply, "Invalid steamid.")

        return
    end

    for _, v in ipairs(player.GetAll()) do
        if v:SteamID() == steamid then
            ulx.checkprivileges(calling_ply, v)

            return
        end
    end

    local privilegesHas = {}

    for k, v in pairs(ULib.playerPrivileges) do
        if ULib.hasPrivilege(steamid, v) then
            table.insert(privilegesHas, k)
        end
    end

    if #privilegeHas == 0 then
        ULib.tsayError(calling_ply, "Target has no privileges", true)

        return
    end

    ulx.fancyLog({calling_ply}, "#s has privileges <#s>", steamid, table.concat(privilegeHas, ", "))
end

local checkprivilegesid = ulx.command(CATEGORY_NAME, "ulx checkprivilegeid", ulx.checkprivilegeid, "!cpi")

checkprivilegesid:addParam{
    type = ULib.cmds.StringArg,
    hint = "steamid"
}

checkprivilegesid:defaultAccess(ULib.ACCESS_SUPERADMIN)
checkprivilegesid:help("Check what privileges a player has.")
