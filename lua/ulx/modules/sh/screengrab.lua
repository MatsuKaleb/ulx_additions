local CATEGORY_NAME = "Utility"

function ulx.screengrab(calling_ply, target_ply, quality)
    ScreenCapture(calling_ply, target_ply, quality)
    ulx.fancyLogAdmin(calling_ply, true, "#A screengrabbed #T", target_ply)
end

local screengrab = ulx.command(CATEGORY_NAME, "ulx screengrab", ulx.screengrab, "!screengrab")

screengrab:addParam{
    type = ULib.cmds.PlayerArg
}

screengrab:addParam{
    type = ULib.cmds.NumArg,
    min = 1,
    max = 50,
    default = 25,
    hint = "quality",
    ULib.cmds.optional
}

screengrab:defaultAccess(ULib.ACCESS_SUPERADMIN)
screengrab:help("Create a capture of a player's screen.")
