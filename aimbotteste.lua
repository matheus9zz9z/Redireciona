--[[

	Universal Aimbot Module by Exunys © CC0 1.0 Universal (2023 - 2024)
	https://github.com/Exunys

]]

--// Cache

local game, workspace = game, workspace
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick, mathrandom = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick, math.random
local Vector2new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp

local GameMetatable = getrawmetatable and getrawmetatable(game) or {
	__index = function(self, Index)
		return self[Index]
	end,

	__newindex = function(self, Index, Value)
		self[Index] = Value
	end
}

local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex

local GetService = __index(game, "GetService")

--// Services

local RunService = GetService(game, "RunService")
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local Players = GetService(game, "Players")

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}

--// Aimbot Configuração
getgenv().ExunysDeveloperAimbot = {
	Settings = {
		Enabled = true,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		Sensitivity = 0,
		Sensitivity2 = 3.5,
		LockMode = 1, -- 1 = CFrame; 2 = mousemoverel
		TriggerKey = Enum.UserInputType.MouseButton2,
		Toggle = false
	},
	Blacklisted = {},
}

local Environment = getgenv().ExunysDeveloperAimbot

--// Função para escolher a parte do corpo aleatoriamente
local function GetRandomLockPart()
	return mathrandom(1, 100) <= 70 and "HumanoidRootPart" or "Head"
end

--// Função principal para encontrar o jogador mais próximo
local function GetClosestPlayer()
	local LockPart = GetRandomLockPart() -- Escolhe aleatoriamente
	RequiredDistance = 2000
	for _, Player in next, Players:GetPlayers() do
		if Player ~= Players.LocalPlayer and not tablefind(Environment.Blacklisted, Player.Name) then
			local Character = Player.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			if Character and Humanoid and Character:FindFirstChild(LockPart) then
				local PartPosition = Character[LockPart].Position
				local Vector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(PartPosition)
				local Distance = (UserInputService:GetMouseLocation() - Vector2new(Vector.X, Vector.Y)).Magnitude
				if Distance < RequiredDistance and OnScreen then
					RequiredDistance = Distance
					Environment.Locked = Player
				end
			end
		end
	end
end

--// Loop principal
RunService.RenderStepped:Connect(function()
	if Environment.Settings.Enabled and Running then
		GetClosestPlayer()
		if Environment.Locked then
			local LockPart = GetRandomLockPart() -- Reescolher para cada mira
			local LockedPosition = Environment.Locked.Character[LockPart].Position
			workspace.CurrentCamera.CFrame = CFramenew(workspace.CurrentCamera.CFrame.Position, LockedPosition)
		end
	end
end)

--// Entrada do jogador
UserInputService.InputBegan:Connect(function(Input)
	if Input.UserInputType == Environment.Settings.TriggerKey then
		Running = not Running
		if not Running then Environment.Locked = nil end
	end
end)

return Environment
