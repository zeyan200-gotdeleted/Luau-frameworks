local ThemeEngine do
	local ThemeEngine = {}; ThemeEngine.__index = ThemeEngine

	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	
	function ThemeEngine.new( )
		local self = setmetatable({}, ThemeEngine)
		self.RegisteredElements = {}
		self.Themes = {}
		self.CurrentThemeName = nil
		self.OnThemeChanged = Instance.new("BindableEvent")
    
		return self
	end

	function ThemeEngine:Register( element, properties )
		assert(element and type(properties) == "table", "Invalid registration")
		self.RegisteredElements[element] = properties
	end

	function ThemeEngine:AddTheme( themeName, themeData )
		assert(type(themeName) == "string" and type(themeData) == "table", "Invalid theme")
		self.Themes[themeName] = themeData
	end

	function ThemeEngine:SetTheme( themeName, tween Duration )
		local themeData = self.Themes[themeName]
    
		if not themeData then error("Theme not found: "..themeName) end
    
		self.CurrentThemeName = themeName
    
		for element, properties in self.RegisteredElements do
			for _, propertyName in pairs(properties) do
        
				local value = themeData[propertyName]
		
        if value then
					if tweenDuration and tweenDuration > 0 then
						
            local tweenInfo = TweenInfo.new(tween Duration) 
            local tween = TweenService:Create(element, tweenInfo, {[propertyName] = value})
			
            tween:Play()
					
          else
				
            element[propertyName] = value
					
          end
				end
			end
		end
    
		self.OnThemeChanged:Fire( themeName ) 
	end

	function ThemeEngine:GetCurrentTheme( )
		return self.CurrentThemeName
	end

	function ThemeEngine:GetTheme( themeName )
		return self.Themes[themeName]
	end

	function ThemeEngine:GetAllThemes( )
		local names = {}
    
		for name in self.Themes do
			table.insert(names, name)
		end
    
		return names
	end

	return ThemeEngine
end

return ThemeEngine
