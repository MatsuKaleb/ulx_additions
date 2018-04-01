PRIV_TRUSTED = 1
PRIV_DONATOR = 2

ULib.playerPrivileges = {

    ["trusted"] = PRIV_TRUSTED,
    ["donator"] = PRIV_DONATOR,

}

local plyMeta = FindMetaTable("Player")

if SERVER then
    hook.Add("PlayerInitialSpawn", "RestorePrivilege", function(ply)
        local privileges = ply:GetPData("ulib_privileges")

        if privileges then
            ply:SetNWInt("ulib_privileges", tonumber(privileges))
        end
    end)

    function plyMeta:GrantPrivilege(grant)
        local privileges = self:GetNWInt("ulib_privileges", 0)

        privileges = bit.bor(privileges, grant)

        self:SetNWInt("ulib_privileges", privileges)
        self:SetPData("ulib_privileges", privileges)
    end

    function plyMeta:RevokePrivilege(revoke)
        local privileges = self:GetNWInt("ulib_privileges", 0)

        privileges = bit.band(privileges, bit.bnot(revoke))

        self:SetNWInt("ulib_privileges", privileges)
        self:SetPData("ulib_privileges", privileges)
    end

    function ULib.grantPrivilege(steamid, grant)
        local privileges = util.GetPData(steamid, "ulib_privileges", 0)

        privileges = tonumber(privileges)

        if privileges then
            privileges = bit.bor(privileges, grant)

            util.SetPData(steamid, "ulib_privileges", privileges)
        end
    end

    function ULib.revokePrivilege(steamid, revoke)
        local privileges = util.GetPData(steamid, "ulib_privileges", 0)

        privileges = tonumber(privileges)

        if privileges then
            privileges = bit.band(privileges, bit.bnot(revoke))

            util.SetPData(steamid, "ulib_privileges", privileges)
        end
    end
end

function plyMeta:HasPrivilege(privilege)
    local privileges = self:GetNWInt("ulib_privileges", 0)

    if privileges then
        return bit.band(privileges, privilege) == privilege
    end

    return false
end

function ULib.hasPrivilege(steamid, privilege)
    local privileges = util.GetPData(steamid, "ulib_privileges", 0)

    privileges = tonumber(privileges)

    if privileges then
        return bit.band(privileges, privilege) == privilege
    end

    return false
end
