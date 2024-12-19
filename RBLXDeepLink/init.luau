-- Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
-- Copyright (c) 2024 Metatable Games. All rights reserved.

local HttpService = game:GetService("HttpService")
local Types = require(script:WaitForChild("Types"))

local DATA_LENGTH_LIMIT: number = 200
local REGULAR_FORMAT: string = "https://www.roblox.com/games/start?placeId=%*&launchData=%*"
local APPSFLYER_FORMAT: string = "https://ro.blox.com/Ebh5?af_dp=%*&af_web_dp=%*"

local RBLXDeepLink = {}
RBLXDeepLink.Enum = require(script:WaitForChild("Enum"))
RBLXDeepLink.Base64 = require(script:WaitForChild("Base64"))
RBLXDeepLink.URLEncode = require(script:WaitForChild("URLEncode"))

function RBLXDeepLink:Decode(data: string, doubleEncode: boolean?): any
    doubleEncode = doubleEncode or false

    data = RBLXDeepLink.URLEncode.urldecode(data)

    if doubleEncode then
        data = RBLXDeepLink.Base64.decode(data)
    end

	return HttpService:JSONDecode(data)
end

function RBLXDeepLink:Encode(data: any, doubleEncode: boolean?): string
    doubleEncode = doubleEncode or false

	data = HttpService:JSONEncode(data)

    if doubleEncode then
        data = RBLXDeepLink.Base64.encode(data)
    end

    return RBLXDeepLink.URLEncode.urlencode(data)
end

function RBLXDeepLink:GetLaunchData(Player: Player): string?
	local LaunchData = Player:GetJoinData().LaunchData
    
	if LaunchData and #LaunchData ~= 0 then
        return string.match(RBLXDeepLink.URLEncode.urldecode(LaunchData), "&launchdata=([^&]+)")
    end

    return nil
end

function RBLXDeepLink.new(RBLXDeepLinkType: Types.RBLXDeepLinkType, data: string, placeId: number?): string?
	if #data > DATA_LENGTH_LIMIT then
		warn("Data length exceeds the limit of " .. DATA_LENGTH_LIMIT .. " characters.")
		return nil
	end

    placeId = placeId or game.PlaceId

    if RBLXDeepLinkType == RBLXDeepLinkType.Enum.RBLXDeepLinkType.Default then
        return string.format(REGULAR_FORMAT, placeId, data)
    end

    if RBLXDeepLinkType == RBLXDeepLinkType.Enum.RBLXDeepLinkType.Appsflyer then
        return string.format(APPSFLYER_FORMAT, RBLXDeepLink.new("Default", data, placeId), RBLXDeepLink.new("Default", data, placeId))
    end

    return nil
end

export type RBLXDeepLink = {
    new: (RBLXDeepLinkType: Types.RBLXDeepLinkType, data: string) -> string?;
    Decode: (data: string, doubleEncode: boolean?) -> any;
    Encode: (data: any, doubleEncode: boolean?) -> string;
    GetLaunchData: (Player: Player) -> string?;
}  & typeof(RBLXDeepLink)

return RBLXDeepLink