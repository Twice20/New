-- Client-side script
-- Работает в обычном LocalScript и в клиентском Lua-окружении без executor-специфичных API.
if not game:IsLoaded() then game.Loaded:Wait() end
-- Полное меню: главное окно + панель настроек + вкладка "Скрипты" (3D музыка с текстом) + первое лицо
-- Открыть/закрыть: INS (бинд меняется кликом по кнопке бинда)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")
local player = Players.LocalPlayer
if not player then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	player = Players.LocalPlayer
end

----------------------------------------------------------------
-- НАСТРОЙКИ ДЛЯ ТЕБЯ
----------------------------------------------------------------
-- Свои картинки вместо нарисованных иконок: ICON_IDS.note = "rbxassetid://123"
-- Имена: star globe people image island wand tools note cloud gear plane camera panel notif upcircle
-- radius eyeslash eye drop check settings person align dots bar xp expand logs bind_menu bind_reload
-- loop anim shadows scale visuals brush pause volume subs search lang blur
local ICON_IDS = {}

-- Готовый текст для конкретной музыки (необязательно, можно вставлять текст прямо в меню):
-- LYRICS["ID_МУЗЫКИ"] = { {0, "Первая строка"}, {5.5, "Second line"} }
local LYRICS = {}

----------------------------------------------------------------
-- Цвета / шрифт
----------------------------------------------------------------
local C = {
	bg = Color3.fromRGB(14, 14, 21),
	rail = Color3.fromRGB(11, 11, 17),
	side = Color3.fromRGB(16, 16, 24),
	card = Color3.fromRGB(17, 17, 25),
	line = Color3.fromRGB(30, 30, 40),
	field = Color3.fromRGB(26, 26, 36),
	accent = Color3.fromRGB(235, 80, 140),
	text = Color3.fromRGB(225, 225, 232),
	title = Color3.fromRGB(190, 190, 200),
	dim = Color3.fromRGB(140, 140, 155),
	off = Color3.fromRGB(45, 45, 55),
}
local FONT = Enum.Font.Gotham
local animMul = 1

----------------------------------------------------------------
-- Локализация
----------------------------------------------------------------
local LANG = {
	ru = {
		main = "Главная", look = "Внешний вид", dash = "—", search = "Поиск",
		bind_menu = "Бинд меню", bind_reload = "Бинд перезагрузки", logs = "Окно логов", island = "Остров биндов",
		lang = "Язык", anim = "Длит. анимации", blur = "Размытие меню", shadows = "Отключить тени",
		scale = "Масштаб меню", visuals = "Включить визуалы", notif = "Уведомления", theme = "Тема",
		log_title = "Лог изменений", isl_menu = "Меню", isl_reload = "Перезагрузка",
		on = "вкл", off = "выкл", reloaded = "Настройки сброшены",
		t_info = "Инфо экран", t_scripts = "Скрипты",
		s_agro = "Агро линии", s_cam = "Камера", s_heroes = "Оверлей героев", s_infoov = "Инфо оверлея",
		s_notif = "Уведомления", s_off = "Вне экрана", s_radius = "Радиус", s_show = "Показать боль...",
		s_vis = "Видимость", s_help = "Помощник вар...", s_music = "3D музыка",
		c_items = "Оверлей предметов", c_skills = "Оверлей скиллов", c_mods = "Оверлей модификаторов",
		c_bars = "Оверлей полосок", c_extra = "Доп. настройки", c_music = "Музыка", c_subs = "3D субтитры",
		c_cam = "Камера", c_lyrics = "Текст песни",
		r_enable = "Включить", r_settings = "Настройки", r_showon = "Показывать на", r_align = "Выравнивание",
		r_compact = "Компактно", r_ownbars = "Свои полоски", r_xp = "Опыт", r_hover = "Радиус наведения",
		m_id = "ID музыки", m_enter = "Ввести", m_enter_id = "Введите ID музыки", m_loading = "Загрузка...",
		m_failed = "Не удалось загрузить", m_playing = "Играет: ",
		music_pause = "Пауза", music_loop = "Повтор", music_vol = "Громкость",
		subs = "3D субтитры", subs_anim = "Анимация", subs_color = "Цвет", subs_align = "Выравнивание",
		subs_offset = "Сдвиг текста", fp = "Режим первого лица",
		l_placeholder = "Вставь текст песни (русский или English). Можно с таймкодами: [01:23] строка",
		l_hint = "Просто строки или LRC: [мм:сс.xx] текст",
		l_apply = "Применить", l_clear = "Очистить", l_lines = "Строк: ",
		l_timed = "по таймкодам", l_auto = "авто-тайминг", l_none = "текст не задан",
		a_type = "Печать", a_wave = "Волна", a_fall = "Падение", a_zoom = "Масштаб", a_spin = "Вращение",
		k_pink = "Розовый", k_rainbow = "Радуга", k_neon = "Неон", k_sunset = "Закат", k_ice = "Лёд", k_gold = "Золото",
		a_left = "Слева", a_center = "По центру", a_right = "Справа",
	},
	en = {
		main = "Main", look = "Appearance", dash = "—", search = "Search",
		bind_menu = "Menu bind", bind_reload = "Reload bind", logs = "Logs window", island = "Binds island",
		lang = "Language", anim = "Anim. duration", blur = "Menu blur", shadows = "Disable shadows",
		scale = "Menu scale", visuals = "Enable visuals", notif = "Notifications", theme = "Theme",
		log_title = "Change log", isl_menu = "Menu", isl_reload = "Reload",
		on = "on", off = "off", reloaded = "Settings reset",
		t_info = "Info screen", t_scripts = "Scripts",
		s_agro = "Aggro lines", s_cam = "Camera", s_heroes = "Hero overlay", s_infoov = "Overlay info",
		s_notif = "Notifications", s_off = "Off-screen", s_radius = "Radius", s_show = "Show more...",
		s_vis = "Visibility", s_help = "Var helper...", s_music = "3D music",
		c_items = "Item overlay", c_skills = "Skill overlay", c_mods = "Modifier overlay",
		c_bars = "Bar overlay", c_extra = "Extra settings", c_music = "Music", c_subs = "3D subtitles",
		c_cam = "Camera", c_lyrics = "Lyrics",
		r_enable = "Enable", r_settings = "Settings", r_showon = "Show on", r_align = "Alignment",
		r_compact = "Compact", r_ownbars = "Own bars", r_xp = "Experience", r_hover = "Hover radius",
		m_id = "Music ID", m_enter = "Enter", m_enter_id = "Enter a music ID", m_loading = "Loading...",
		m_failed = "Failed to load", m_playing = "Playing: ",
		music_pause = "Pause", music_loop = "Loop", music_vol = "Volume",
		subs = "3D subtitles", subs_anim = "Animation", subs_color = "Color", subs_align = "Alignment",
		subs_offset = "Text offset", fp = "First person mode",
		l_placeholder = "Paste lyrics (English or Русский). Timestamps optional: [01:23] line",
		l_hint = "Plain lines or LRC: [mm:ss.xx] text",
		l_apply = "Apply", l_clear = "Clear", l_lines = "Lines: ",
		l_timed = "timestamps", l_auto = "auto timing", l_none = "no lyrics",
		a_type = "Typing", a_wave = "Wave", a_fall = "Fall", a_zoom = "Zoom", a_spin = "Spin",
		k_pink = "Pink", k_rainbow = "Rainbow", k_neon = "Neon", k_sunset = "Sunset", k_ice = "Ice", k_gold = "Gold",
		a_left = "Left", a_center = "Center", a_right = "Right",
	},
}
local curLang = "ru"
local function T(k) return LANG[curLang][k] or k end

----------------------------------------------------------------
-- Хелперы
----------------------------------------------------------------
local tracked = setmetatable({}, { __mode = "k" })
local function track(obj, prop)
	tracked[obj] = tracked[obj] or {}
	tracked[obj][prop] = true
end

local function new(class, props, parent)
	local o = Instance.new(class)
	if o:IsA("GuiObject") then o.BorderSizePixel = 0 end
	if o:IsA("GuiButton") then o.AutoButtonColor = false end
	if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
		o.Font = FONT; o.Text = ""; o.TextColor3 = C.text
	end
	for k, v in pairs(props) do
		o[k] = v
		if typeof(v) == "Color3" and v == C.accent then track(o, k) end
	end
	o.Parent = parent
	return o
end

local function corner(o, r) new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function stroke(o, col) return new("UIStroke", { Color = col or C.line, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o) end
local function tw(o, props, t)
	TS:Create(o, TweenInfo.new((t or 0.15) * animMul, Enum.EasingStyle.Quad), props):Play()
end
local function txt(parent, text, pos, size, sz, color, align)
	return new("TextLabel", {
		BackgroundTransparency = 1, Text = text, TextSize = sz or 14, TextColor3 = color or C.text,
		TextXAlignment = align or Enum.TextXAlignment.Left, Position = pos, Size = size,
	}, parent)
end

local function setTheme(col)
	local old = C.accent
	C.accent = col
	for obj, ps in pairs(tracked) do
		for p in pairs(ps) do
			if obj[p] == old then obj[p] = col end
		end
	end
end

local trList = {}
local function tl(parent, key, pos, size, sz, color, align)
	local l = txt(parent, T(key), pos, size, sz, color, align)
	local e = { l, key }
	table.insert(trList, e)
	return l, e
end

----------------------------------------------------------------
-- Состояние
----------------------------------------------------------------
local state, defaults, effects, ui, labels, displayOf = {}, {}, {}, {}, {}, {}
local uiFns, dropRefresh = {}, {}
local open = false
local listening = nil
local toast, addLog

local function regUI(key, fn)
	uiFns[key] = uiFns[key] or {}
	table.insert(uiFns[key], fn)
	ui[key] = function(v)
		for _, f in ipairs(uiFns[key]) do f(v) end
	end
end

local function keyName(k) return k == Enum.KeyCode.Insert and "INS" or k.Name:upper() end
local function fmtVal(v)
	if type(v) == "boolean" then return v and T("on") or T("off") end
	if type(v) == "number" then return tostring(math.floor(v * 100 + 0.5) / 100) end
	if typeof(v) == "EnumItem" then return keyName(v) end
	return tostring(v)
end

local function change(key, v, silent)
	state[key] = v
	if effects[key] then effects[key](v) end
	if silent then return end
	local shown = displayOf[key] and displayOf[key](v) or fmtVal(v)
	local msg = T(labels[key] or key) .. " → " .. shown
	addLog(msg)
	if state.notif then toast(msg) end
end

local function reload()
	for k, d in pairs(defaults) do
		if ui[k] then ui[k](d) end
		change(k, d, true)
	end
	addLog(T("reloaded"))
	if state.notif then toast(T("reloaded")) end
end

----------------------------------------------------------------
-- GUI корень
----------------------------------------------------------------
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then error("UmbrellaMenu: PlayerGui не найден") end
local oldGui = playerGui:FindFirstChild("UmbrellaMenu")
if oldGui then oldGui:Destroy() end
local gui = new("ScreenGui", {
	Name = "UmbrellaMenu", ResetOnSpawn = false, IgnoreGuiInset = true,
	DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local root = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(1280, 762), BackgroundTransparency = 1, Visible = false,
}, gui)
local scale = new("UIScale", {}, root)
local menuScale = 1
local function getCamera()
	return workspace.CurrentCamera or workspace:WaitForChild("Camera")
end

local function baseScale()
	local cam = getCamera()
	local vp = cam.ViewportSize
	return math.min(1, vp.X / 1300, vp.Y / 780) * menuScale
end

-- Modal-кнопка освобождает курсор при открытом меню (важно для первого лица)
local modal = new("TextButton", {
	Modal = true, Size = UDim2.fromOffset(1, 1), Position = UDim2.fromOffset(-5, -5),
	BackgroundTransparency = 1, Visible = false,
}, gui)

local blur = new("BlurEffect", { Size = 0, Name = "UmbrellaBlur" }, Lighting)
local function updateBlur()
	local target = (open and state.visuals) and (state.blur or 0) or 0
	TS:Create(blur, TweenInfo.new(0.2 * animMul), { Size = target }):Play()
end

local function drag(handle, target)
	local dragging, start, orig
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; start = i.Position; orig = target.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = (i.Position - start) / scale.Scale
			target.Position = UDim2.new(orig.X.Scale, orig.X.Offset + d.X, orig.Y.Scale, orig.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local windows = {}
local function makeWindow(x, y, w, h)
	local wrap = new("Frame", { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1 }, root)
	local sh = new("Frame", {
		Position = UDim2.fromOffset(-10, -4), Size = UDim2.new(1, 20, 1, 20),
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55, Visible = false,
	}, wrap)
	corner(sh, 10)
	local g = new("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.bg, GroupTransparency = 1 }, wrap)
	corner(g, 4); stroke(g, Color3.fromRGB(24, 24, 32))
	table.insert(windows, { group = g, shadow = sh })
	return wrap, g
end

local overlay
local function closePopup()
	if overlay then for _, c in ipairs(overlay:GetChildren()) do c:Destroy() end end
end

local openToken = 0
local function setOpen(v)
	openToken += 1
	local tok = openToken
	local was = root.Visible
	open = v
	modal.Visible = v
	if v and not was then
		for _, w in ipairs(windows) do w.group.GroupTransparency = 1; w.shadow.BackgroundTransparency = 1 end
		scale.Scale = baseScale() * 0.94
		root.Visible = true
	end
	updateBlur()
	if state.visuals and animMul > 0 then
		local t = 0.2 * animMul
		local info = TweenInfo.new(t, Enum.EasingStyle.Quad)
		for _, w in ipairs(windows) do
			TS:Create(w.group, info, { GroupTransparency = v and 0 or 1 }):Play()
			TS:Create(w.shadow, info, { BackgroundTransparency = v and 0.55 or 1 }):Play()
		end
		TS:Create(scale, info, { Scale = baseScale() * (v and 1 or 0.94) }):Play()
		if not v then
			task.delay(t, function() if tok == openToken then root.Visible = false end end)
		end
	else
		for _, w in ipairs(windows) do w.group.GroupTransparency = v and 0 or 1; w.shadow.BackgroundTransparency = 0.55 end
		scale.Scale = baseScale()
		root.Visible = v
	end
	if not v then closePopup() end
end
getCamera():GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if open then scale.Scale = baseScale() end
end)

----------------------------------------------------------------
-- ИКОНКИ: единый стиль "линия 1.5px со скруглёнными концами" (16x16)
----------------------------------------------------------------
local function line(p, x1, y1, x2, y2, col, th)
	th = th or 1.5
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	local f = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
		Size = UDim2.fromOffset(math.max(len, th), th), Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = col,
	}, p)
	corner(f, th / 2)
	return f
end
local function poly(p, pts, col, th, closed)
	for i = 1, #pts - 1 do line(p, pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], col, th) end
	if closed then line(p, pts[#pts][1], pts[#pts][2], pts[1][1], pts[1][2], col, th) end
end
local function dot(p, cx, cy, d, col)
	local f = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(d, d), BackgroundColor3 = col,
	}, p)
	corner(f, d / 2)
	return f
end
local function oval(p, cx, cy, rx, ry, col, th)
	th = th or 1.4
	local f = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy),
		Size = UDim2.fromOffset(math.max(rx * 2 - th * 2, 1), math.max(ry * 2 - th * 2, 1)), BackgroundTransparency = 1,
	}, p)
	new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
	new("UIStroke", { Color = col, Thickness = th }, f)
end
local function circ(p, cx, cy, r, col, th) oval(p, cx, cy, r, r, col, th) end
local function rrect(p, x, y, w, h, r, col, th)
	th = th or 1.4
	local f = new("Frame", {
		Position = UDim2.fromOffset(x + th, y + th), Size = UDim2.fromOffset(w - th * 2, h - th * 2), BackgroundTransparency = 1,
	}, p)
	corner(f, r)
	new("UIStroke", { Color = col, Thickness = th }, f)
end
local function arc(p, cx, cy, r, a0, a1, col, th, steps)
	steps = steps or 10
	local pts = {}
	for i = 0, steps do
		local a = math.rad(a0 + (a1 - a0) * i / steps)
		pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
	end
	poly(p, pts, col, th)
end
local function clip(p, x, y, w, h)
	return new("Frame", { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundTransparency = 1, ClipsDescendants = true }, p)
end
local function arrowHead(p, ex, ey, tx, ty, c, th, len)
	local ang = math.atan2(ty, tx)
	for _, s in ipairs({ 1, -1 }) do
		local a = ang + math.pi + s * math.rad(35)
		line(p, ex, ey, ex + len * math.cos(a), ey + len * math.sin(a), c, th)
	end
end
local function knob(p, x, y, c, bg)
	dot(p, x, y, 6, bg); circ(p, x, y, 2.6, c, 1.4)
end

local ICONS = {}
ICONS.check = function(p, c) poly(p, { { 2.5, 8.5 }, { 6.3, 12 }, { 13.5, 4.5 } }, c, 2) end
ICONS.settings = function(p, c, bg)
	line(p, 2, 4.5, 14, 4.5, c); line(p, 2, 11.5, 14, 11.5, c)
	knob(p, 10, 4.5, c, bg); knob(p, 5.5, 11.5, c, bg)
end
ICONS.person = function(p, c)
	circ(p, 8, 4.8, 3, c)
	local k = clip(p, 0, 9, 16, 7); oval(k, 8, 9, 6, 6, c)
end
ICONS.people = function(p, c)
	circ(p, 6, 5, 2.7, c)
	local k = clip(p, 0, 9, 13, 7); oval(k, 6, 7, 5.5, 5.5, c)
	circ(p, 11.8, 5.2, 2.1, c)
	arc(p, 11.8, 13.2, 4.2, -150, -35, c, 1.4, 6)
end
ICONS.align = function(p, c) line(p, 2, 3.5, 14, 3.5, c); line(p, 6, 8, 14, 8, c); line(p, 4, 12.5, 14, 12.5, c) end
ICONS.dots = function(p, c) dot(p, 3, 8, 2.8, c); dot(p, 8, 8, 2.8, c); dot(p, 13, 8, 2.8, c) end
ICONS.bar = function(p, c) rrect(p, 1, 4.5, 14, 7, 3.5, c); line(p, 4, 8, 8.5, 8, c, 2) end
ICONS.xp = function(p, c) line(p, 1, 8, 5, 8, c); circ(p, 8, 8, 3, c); line(p, 11, 8, 15, 8, c) end
ICONS.expand = function(p, c)
	poly(p, { { 10, 2 }, { 14, 2 }, { 14, 6 } }, c); poly(p, { { 6, 14 }, { 2, 14 }, { 2, 10 } }, c)
	line(p, 14, 2, 9, 7, c); line(p, 2, 14, 7, 9, c)
end
ICONS.star = function(p, c)
	local pts = {}
	for i = 0, 9 do
		local a = -math.pi / 2 + i * math.pi / 5
		local r = (i % 2 == 0) and 7.2 or 3.1
		pts[#pts + 1] = { 8 + r * math.cos(a), 8.6 + r * math.sin(a) }
	end
	poly(p, pts, c, 1.4, true)
end
ICONS.globe = function(p, c) circ(p, 8, 8, 7, c); line(p, 1.2, 8, 14.8, 8); oval(p, 8, 8, 3, 7, c) end
ICONS.lang = ICONS.globe
ICONS.image = function(p, c)
	rrect(p, 1, 2, 14, 12, 2.5, c); dot(p, 11, 6, 2.6, c)
	poly(p, { { 2, 12 }, { 6, 8 }, { 9, 11 }, { 11, 9.2 }, { 14, 12 } }, c, 1.4)
end
ICONS.island = function(p, c)
	local k = clip(p, 0, 1, 16, 8); oval(k, 8, 7, 7.2, 7.2, c)
	line(p, 8, 8, 8, 13.5, c); arc(p, 6.4, 13.5, 1.6, 0, 180, c, 1.4, 6)
end
ICONS.wand = function(p, c)
	line(p, 2.5, 13.5, 9.5, 6.5, c, 2)
	line(p, 12, 1.5, 12, 6, c, 1.3); line(p, 9.8, 3.8, 14.2, 3.8, c, 1.3); dot(p, 14, 10, 2, c)
end
ICONS.tools = function(p, c)
	line(p, 3, 3, 13, 13, c, 2); line(p, 13, 3, 3, 13, c, 2)
	dot(p, 3, 3, 3.6, c); dot(p, 13, 3, 3.6, c); dot(p, 3, 13, 3.6, c); dot(p, 13, 13, 3.6, c)
end
ICONS.note = function(p, c)
	dot(p, 4, 12.5, 5, c); dot(p, 11.2, 11, 5, c)
	line(p, 6.2, 12, 6.2, 3.6, c, 1.6); line(p, 13.4, 10.5, 13.4, 2.2, c, 1.6); line(p, 6.2, 3.6, 13.4, 2.2, c, 2.2)
end
ICONS.cloud = function(p, c, bg)
	local function shape(col, ins)
		dot(p, 4.5, 10.5, 7 - ins * 2, col); dot(p, 8.2, 7.2, 8.4 - ins * 2, col); dot(p, 12, 10.5, 7 - ins * 2, col)
		new("Frame", { Position = UDim2.fromOffset(4.5, 10.5 - ins * 0), Size = UDim2.fromOffset(7.5, 3.5 - ins), BackgroundColor3 = col }, p)
	end
	shape(c, 0); shape(bg, 1.5)
end
ICONS.gear = function(p, c)
	circ(p, 8, 8, 4.4, c, 1.5); circ(p, 8, 8, 1.8, c, 1.2)
	for k = 0, 7 do
		local a = math.rad(k * 45)
		line(p, 8 + 5.4 * math.cos(a), 8 + 5.4 * math.sin(a), 8 + 7.3 * math.cos(a), 8 + 7.3 * math.sin(a), c, 2.4)
	end
end
ICONS.plane = function(p, c)
	poly(p, { { 1, 8 }, { 15, 1.5 }, { 10.5, 14.5 }, { 7.5, 9.5 } }, c, 1.4, true); line(p, 15, 1.5, 7.5, 9.5, c, 1.4)
end
ICONS.camera = function(p, c)
	rrect(p, 1, 4, 14, 10, 2.5, c); circ(p, 8, 9, 3, c)
	poly(p, { { 5.5, 4 }, { 6.5, 2 }, { 9.5, 2 }, { 10.5, 4 } }, c, 1.4)
end
ICONS.panel = function(p, c) rrect(p, 1, 2, 14, 12, 2.2, c); line(p, 1.5, 6, 14.5, 6, c, 1.3); line(p, 6, 6, 6, 13.5, c, 1.3) end
ICONS.upcircle = function(p, c)
	circ(p, 8, 8, 7, c); line(p, 8, 11.5, 8, 5, c); poly(p, { { 5, 7.8 }, { 8, 4.8 }, { 11, 7.8 } }, c)
end
ICONS.radius = function(p, c) circ(p, 8, 8, 7, c); circ(p, 8, 8, 3.6, c); dot(p, 8, 8, 2, c) end
local function eyeShape(p, c)
	local top, bot = {}, {}
	for i = 0, 10 do
		local t = i / 10
		local y = 5 * math.sin(math.pi * t)
		top[#top + 1] = { 1 + 14 * t, 8 - y }
		bot[#bot + 1] = { 1 + 14 * t, 8 + y }
	end
	poly(p, top, c, 1.4); poly(p, bot, c, 1.4)
	circ(p, 8, 8, 2.4, c); dot(p, 8, 8, 1.6, c)
end
ICONS.eye = eyeShape
ICONS.eyeslash = function(p, c, bg)
	eyeShape(p, c); line(p, 2.5, 14, 13.5, 2, bg, 3.6); line(p, 2.5, 14, 13.5, 2, c, 1.5)
end
ICONS.drop = function(p, c)
	poly(p, { { 3.4, 8.4 }, { 8, 1.5 }, { 12.6, 8.4 } }, c, 1.4); circ(p, 8, 10, 5, c)
end
ICONS.blur = ICONS.drop
ICONS.search = function(p, c) circ(p, 6.8, 6.8, 4.8, c); line(p, 10.4, 10.4, 14, 14, c, 1.8) end
ICONS.logs = function(p, c)
	rrect(p, 3, 1, 10, 14, 2, c)
	line(p, 5.6, 5, 10.4, 5, c, 1.3); line(p, 5.6, 8, 10.4, 8, c, 1.3); line(p, 5.6, 11, 8.6, 11, c, 1.3)
end
ICONS.bind_menu = function(p, c)
	rrect(p, 0.8, 3, 14.4, 10, 2.2, c)
	dot(p, 4, 6.4, 1.6, c); dot(p, 7, 6.4, 1.6, c); dot(p, 10, 6.4, 1.6, c); dot(p, 12.6, 6.4, 1.6, c)
	line(p, 4.6, 10, 11.4, 10, c, 1.3)
end
ICONS.bind_reload = function(p, c)
	arc(p, 8, 8, 5.5, -10, 290, c, 1.5, 18)
	local th = math.rad(290)
	arrowHead(p, 8 + 5.5 * math.cos(th), 8 + 5.5 * math.sin(th), -math.sin(th), math.cos(th), c, 1.5, 3.2)
end
ICONS.loop = ICONS.bind_reload
ICONS.anim = function(p, c) circ(p, 8, 8, 7, c); line(p, 8, 4, 8, 8, c); line(p, 8, 8, 11, 10, c) end
ICONS.shadows = function(p, c)
	circ(p, 8, 8, 6.8, c, 1.4)
	local k = clip(p, 1.2, 1.2, 6.8, 13.6); dot(k, 6.8, 6.8, 12.4, c)
end
ICONS.scale = function(p, c)
	poly(p, { { 2, 6 }, { 2, 2 }, { 6, 2 } }, c); poly(p, { { 10, 2 }, { 14, 2 }, { 14, 6 } }, c)
	poly(p, { { 14, 10 }, { 14, 14 }, { 10, 14 } }, c); poly(p, { { 6, 14 }, { 2, 14 }, { 2, 10 } }, c)
end
ICONS.visuals = function(p, c)
	poly(p, { { 8, 1 }, { 9.7, 6.3 }, { 15, 8 }, { 9.7, 9.7 }, { 8, 15 }, { 6.3, 9.7 }, { 1, 8 }, { 6.3, 6.3 } }, c, 1.3, true)
end
ICONS.brush = function(p, c)
	circ(p, 8, 8, 7, c)
	dot(p, 5, 7, 2, c); dot(p, 8.5, 4.6, 2, c); dot(p, 11.3, 8, 2, c); dot(p, 6, 11, 2, c)
end
ICONS.notif = function(p, c)
	local pts = { { 3, 12.2 }, { 4.6, 10.6 }, { 4.6, 7.4 } }
	for i = 1, 8 do
		local a = math.rad(180 + 180 * i / 9)
		pts[#pts + 1] = { 8 + 3.4 * math.cos(a), 7.4 + 3.4 * math.sin(a) }
	end
	pts[#pts + 1] = { 11.4, 7.4 }; pts[#pts + 1] = { 11.4, 10.6 }; pts[#pts + 1] = { 13, 12.2 }
	poly(p, pts, c, 1.4, true); dot(p, 8, 14.4, 2.6, c); line(p, 8, 1.8, 8, 3.2, c, 1.4)
end
ICONS.pause = function(p, c) line(p, 5.5, 3, 5.5, 13, c, 2.8); line(p, 10.5, 3, 10.5, 13, c, 2.8) end
ICONS.volume = function(p, c)
	poly(p, { { 1.5, 6 }, { 4.5, 6 }, { 8, 3 }, { 8, 13 }, { 4.5, 10 }, { 1.5, 10 } }, c, 1.3, true)
	arc(p, 8.5, 8, 3.6, -45, 45, c, 1.4, 6); arc(p, 8.5, 8, 6.4, -50, 50, c, 1.4, 8)
end
ICONS.subs = function(p, c)
	rrect(p, 1, 2, 14, 10, 2.5, c); poly(p, { { 4, 12 }, { 4, 15 }, { 7.5, 12 } }, c, 1.3)
	line(p, 4, 6, 12, 6, c, 1.3); line(p, 4, 8.8, 9, 8.8, c, 1.3)
end

local function makeIcon(parent, name, pos, col, bg)
	local h = new("Frame", { Position = pos, Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1 }, parent)
	local obj = {}
	function obj.set(c)
		h:ClearAllChildren()
		if ICON_IDS[name] then
			new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = ICON_IDS[name], ImageColor3 = c }, h)
		elseif ICONS[name] then
			ICONS[name](h, c, bg)
		end
	end
	obj.set(col)
	return obj
end

local DIM_ICONS = { logs = true, dots = true, xp = true, eyeslash = true }
local function rowIcon(parent, name, h)
	return makeIcon(parent, name, UDim2.fromOffset(11, (h - 16) / 2), DIM_ICONS[name] and C.dim or C.accent, C.card)
end

local function logoIcon(parent, x, y)
	local h = new("Frame", { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1 }, parent)
	local white = Color3.fromRGB(245, 235, 240)
	dot(h, 13, 13, 25, C.accent)
	for k = 0, 3 do
		local a = math.rad(k * 45)
		line(h, 13 + 11.5 * math.cos(a), 13 + 11.5 * math.sin(a), 13 - 11.5 * math.cos(a), 13 - 11.5 * math.sin(a), white, 2.2)
	end
	dot(h, 13, 13, 6, white)
end

----------------------------------------------------------------
-- Уведомления
----------------------------------------------------------------
local toastHolder = new("Frame", {
	AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16),
	Size = UDim2.fromOffset(240, 300), BackgroundTransparency = 1,
}, gui)
new("UIListLayout", {
	VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
}, toastHolder)
local toastN = 0
toast = function(msg)
	toastN += 1
	local f = new("CanvasGroup", {
		Size = UDim2.fromOffset(240, 34), BackgroundColor3 = C.bg, GroupTransparency = 1, LayoutOrder = toastN,
	}, toastHolder)
	corner(f, 4); stroke(f)
	new("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = C.accent }, f)
	local l = txt(f, msg, UDim2.fromOffset(12, 0), UDim2.new(1, -18, 1, 0), 13)
	l.TextTruncate = Enum.TextTruncate.AtEnd
	tw(f, { GroupTransparency = 0 }, 0.2)
	task.delay(2.2, function()
		tw(f, { GroupTransparency = 1 }, 0.25)
		task.delay(0.4, function() f:Destroy() end)
	end)
end

----------------------------------------------------------------
-- Окно логов
----------------------------------------------------------------
local logWrap, logGroup = makeWindow(107, 24, 340, 150)
logWrap.Visible = false
tl(logGroup, "log_title", UDim2.fromOffset(10, 0), UDim2.new(1, -20, 0, 28), 14, C.title)
drag(new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1 }, logGroup), logWrap)
local logScroll = new("ScrollingFrame", {
	Position = UDim2.fromOffset(8, 30), Size = UDim2.new(1, -16, 1, -38), BackgroundTransparency = 1,
	ScrollBarThickness = 3, ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, logGroup)
new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, logScroll)
local logN = 0
addLog = function(msg)
	logN += 1
	local l = txt(logScroll, os.date("[%H:%M:%S] ") .. msg, UDim2.new(), UDim2.new(1, -6, 0, 17), 12, C.dim)
	l.LayoutOrder = logN
	l.TextTruncate = Enum.TextTruncate.AtEnd
	if logN > 80 then
		for _, c in ipairs(logScroll:GetChildren()) do
			if c:IsA("TextLabel") then c:Destroy() break end
		end
	end
	task.defer(function() logScroll.CanvasPosition = Vector2.new(0, 1e6) end)
end

----------------------------------------------------------------
-- Остров биндов
----------------------------------------------------------------
local island = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10),
	AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0), BackgroundColor3 = C.bg, Visible = false,
}, gui)
corner(island, 14); stroke(island, Color3.fromRGB(34, 34, 46))
new("UIPadding", {
	PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
}, island)
local islandLbl = new("TextLabel", {
	AutomaticSize = Enum.AutomaticSize.XY, Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, TextSize = 13,
}, island)
local function updateIsland()
	if not (state.bind_menu and state.bind_reload) then return end
	islandLbl.Text = T("isl_menu") .. ": " .. keyName(state.bind_menu) .. "     " .. T("isl_reload") .. ": " .. keyName(state.bind_reload)
end

----------------------------------------------------------------
-- Компоненты
----------------------------------------------------------------
local function toggle(parent, key, default)
	defaults[key] = default; state[key] = default
	local on = default
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(26, 14), BackgroundColor3 = on and C.accent or C.off,
	}, parent)
	corner(b, 7)
	local k = new("Frame", {
		Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0, 0.5),
		Position = on and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1),
	}, b)
	corner(k, 5)
	regUI(key, function(v)
		on = v
		if on then track(b, "BackgroundColor3") end
		tw(b, { BackgroundColor3 = on and C.accent or C.off })
		tw(k, { Position = on and UDim2.new(1, -12, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
	end)
	b.MouseButton1Click:Connect(function()
		local nv = not on
		ui[key](nv)
		change(key, nv)
	end)
end

-- options: строки ИЛИ пары { значение, ключ_перевода }
local function optVal(o) return type(o) == "table" and o[1] or o end
local function optLbl(o) return type(o) == "table" and T(o[2]) or o end

local function dropdown(parent, key, options, default, w)
	defaults[key] = default; state[key] = default
	local function labelOf(v)
		for _, o in ipairs(options) do
			if optVal(o) == v then return optLbl(o) end
		end
		return tostring(v)
	end
	displayOf[key] = labelOf
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(w, 24), BackgroundColor3 = C.field,
	}, parent)
	corner(b, 3)
	local t = txt(b, labelOf(default), UDim2.fromOffset(8, 0), UDim2.new(1, -26, 1, 0), 13)
	t.TextTruncate = Enum.TextTruncate.AtEnd
	line(b, w - 18, 10.5, w - 15, 13.5, C.dim, 1.5); line(b, w - 15, 13.5, w - 12, 10.5, C.dim, 1.5)
	regUI(key, function(v) t.Text = labelOf(v) end)
	table.insert(dropRefresh, function() t.Text = labelOf(state[key]) end)
	b.MouseButton1Click:Connect(function()
		closePopup()
		local shield = new("TextButton", { Position = UDim2.fromOffset(-3000, -3000), Size = UDim2.fromOffset(6000, 6000), BackgroundTransparency = 1 }, overlay)
		shield.MouseButton1Click:Connect(closePopup)
		local p = (b.AbsolutePosition - root.AbsolutePosition) / scale.Scale
		local list = new("Frame", {
			Position = UDim2.fromOffset(p.X, p.Y + 26), Size = UDim2.fromOffset(w, #options * 24 + 4), BackgroundColor3 = C.field,
		}, overlay)
		corner(list, 3); stroke(list)
		new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2) }, list)
		new("UIListLayout", {}, list)
		for _, opt in ipairs(options) do
			local ob = new("TextButton", {
				Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "  " .. optLbl(opt), TextSize = 13,
				TextColor3 = (optVal(opt) == state[key]) and C.accent or C.text, TextXAlignment = Enum.TextXAlignment.Left,
			}, list)
			ob.MouseEnter:Connect(function() ob.BackgroundColor3 = Color3.new(1, 1, 1); ob.BackgroundTransparency = 0.88 end)
			ob.MouseLeave:Connect(function() ob.BackgroundTransparency = 1 end)
			ob.MouseButton1Click:Connect(function()
				local val = optVal(opt)
				ui[key](val)
				change(key, val)
				closePopup()
			end)
		end
	end)
end

local function bindBtn(parent, key, default)
	defaults[key] = default; state[key] = default
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(34, 14), BackgroundColor3 = C.field, Text = keyName(default), TextSize = 10,
	}, parent)
	corner(b, 2)
	regUI(key, function(v) b.Text = keyName(v) end)
	b.MouseButton1Click:Connect(function()
		listening = key
		b.Text = "..."
	end)
end

local function button(parent, key, anchor, pos, size, bg)
	local isAcc = (bg == C.accent)
	local b = new("TextButton", {
		AnchorPoint = anchor, Position = pos, Size = size, BackgroundColor3 = bg,
		Text = T(key), TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
	}, parent)
	corner(b, 3)
	table.insert(trList, { b, key })
	local small = UDim2.new(size.X.Scale, size.X.Offset - 4, size.Y.Scale, size.Y.Offset - 2)
	b.MouseEnter:Connect(function() tw(b, { BackgroundColor3 = (isAcc and C.accent or bg):Lerp(Color3.new(1, 1, 1), 0.16) }, 0.12) end)
	b.MouseLeave:Connect(function() tw(b, { BackgroundColor3 = isAcc and C.accent or bg }, 0.12) end)
	b.MouseButton1Down:Connect(function() tw(b, { Size = small }, 0.06) end)
	b.MouseButton1Up:Connect(function() tw(b, { Size = size }, 0.12) end)
	b.MouseLeave:Connect(function() tw(b, { Size = size }, 0.12) end)
	return b
end

local function row(parent, o)
	local h = o.h or 34
	labels[o.key] = o.lbl or o.key
	local r = new("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1 }, parent)
	if not o.first then
		new("Frame", { Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 0, 1), BackgroundColor3 = C.line }, r)
	end
	rowIcon(r, o.ic or o.key, h)
	local used = 10
	if o.kind == "toggle" then toggle(r, o.key, o.default); used = 36
	elseif o.kind == "dropdown" then
		local dw = o.dw or 106
		dropdown(r, o.key, o.options, o.default, dw); used = 10 + dw
	elseif o.kind == "bind" then bindBtn(r, o.key, o.default); used = 44
	elseif o.kind == "gear" then
		makeIcon(r, "gear", UDim2.new(1, -26, 0.5, -8), C.text, C.card); used = 28
	end
	if o.gear then
		makeIcon(r, "gear", UDim2.new(1, -(used + 24), 0.5, -8), C.text, C.card)
		used += 28
	end
	local l = tl(r, o.lbl or o.key, UDim2.fromOffset(34, 0), UDim2.new(1, -(34 + used), 1, 0), 14)
	l.TextTruncate = Enum.TextTruncate.AtEnd
	return r
end

local function slider(parent, o)
	local h = 46
	labels[o.key] = o.lbl or o.key
	defaults[o.key] = o.default; state[o.key] = o.default
	local f = new("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1 }, parent)
	if not o.first then
		new("Frame", { Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 0, 1), BackgroundColor3 = C.line }, f)
	end
	rowIcon(f, o.ic or o.key, 30)
	tl(f, o.lbl or o.key, UDim2.fromOffset(34, 0), UDim2.new(0.6, 0, 0, 30), 14)
	local val = txt(f, "", UDim2.new(1, -10, 0, 0), UDim2.fromOffset(100, 30), 14, C.text, Enum.TextXAlignment.Right)
	val.AnchorPoint = Vector2.new(1, 0)
	local track_ = new("Frame", { Position = UDim2.new(0, 10, 0, h - 12), Size = UDim2.new(1, -20, 0, 4), BackgroundColor3 = C.off }, f)
	corner(track_, 2)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent }, track_)
	corner(fill, 2)
	local knobF = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, track_)
	corner(knobF, 6)
	local function apply(v)
		local a = math.clamp((v - o.min) / (o.max - o.min), 0, 1)
		fill.Size = UDim2.fromScale(a, 1)
		knobF.Position = UDim2.fromScale(a, 0.5)
		val.Text = string.format(o.fmt, v)
	end
	apply(o.default)
	regUI(o.key, apply)
	local hit = new("TextButton", { BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, h - 24), Size = UDim2.new(1, -20, 0, 24) }, f)
	local dragging = false
	local function upd(x)
		local a = math.clamp((x - track_.AbsolutePosition.X) / track_.AbsoluteSize.X, 0, 1)
		local v = o.min + (o.max - o.min) * a
		if o.int then v = math.floor(v + 0.5) else v = math.floor(v * 10 + 0.5) / 10 end
		ui[o.key](v)
		change(o.key, v, true)
	end
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true; upd(i.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			upd(i.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			change(o.key, state[o.key])
		end
	end)
end

local function rawCard(parent, titleKey, x, y, w, h)
	local c = new("Frame", { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundColor3 = C.card }, parent)
	corner(c, 4); stroke(c)
	tl(c, titleKey, UDim2.fromOffset(10, 0), UDim2.new(1, -20, 0, 28), 14, C.title)
	return c
end
local function card(parent, titleKey, x, y, w, h)
	local c = rawCard(parent, titleKey, x, y, w, h)
	local body = new("Frame", { Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 1, -28), BackgroundTransparency = 1 }, c)
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, body)
	return body
end

----------------------------------------------------------------
-- ПЕРВОЕ ЛИЦО (плавное приближение + точка по центру)
----------------------------------------------------------------
local ORIG_MIN, ORIG_MAX, ORIG_MODE = player.CameraMinZoomDistance, player.CameraMaxZoomDistance, player.CameraMode
local fpOn, fpToken = false, 0

local dotHolder = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(60, 60), BackgroundTransparency = 1, Visible = false,
}, gui)
local centerDot = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(0, 0), BackgroundColor3 = Color3.new(1, 1, 1),
}, dotHolder)
corner(centerDot, 8)
new("UIStroke", { Color = Color3.fromRGB(10, 10, 20), Thickness = 1, Transparency = 0.35 }, centerDot)
local dotRing = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(6, 6), BackgroundTransparency = 1,
}, dotHolder)
corner(dotRing, 30)
local dotRingStroke = new("UIStroke", { Color = C.accent, Thickness = 2, Transparency = 1 }, dotRing)
local dotToken = 0

local function dotShow(v)
	dotToken += 1
	local tok = dotToken
	if v then
		dotHolder.Visible = true
		centerDot.Size = UDim2.fromOffset(0, 0)
		dotRing.Size = UDim2.fromOffset(6, 6)
		dotRingStroke.Transparency = 0.1
		TS:Create(centerDot, TweenInfo.new(0.45 * animMul, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(6, 6) }):Play()
		TS:Create(dotRing, TweenInfo.new(0.7 * animMul, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(46, 46) }):Play()
		TS:Create(dotRingStroke, TweenInfo.new(0.7 * animMul), { Transparency = 1 }):Play()
	else
		TS:Create(centerDot, TweenInfo.new(0.2 * animMul, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.fromOffset(0, 0) }):Play()
		task.delay(0.25 * animMul, function()
			if tok == dotToken then dotHolder.Visible = false end
		end)
	end
end

local function camDist()
	local char = player.Character
	local head = char and char:FindFirstChild("Head")
	if not head then return 12 end
	local cam = getCamera()
	return (cam.CFrame.Position - head.Position).Magnitude
end

local function applyFP(v)
	if v == fpOn then return end
	fpOn = v
	fpToken += 1
	local tok = fpToken
	local cam = getCamera()
	local baseFov = cam.FieldOfView
	local dur = 0.9 * animMul
	if v then
		dotShow(true)
		local startD = math.max(camDist(), 1)
		player.CameraMinZoomDistance = 0.5
		task.spawn(function()
			local t0 = os.clock()
			while tok == fpToken do
				local a = dur <= 0 and 1 or math.clamp((os.clock() - t0) / dur, 0, 1)
				local e = 1 - (1 - a) ^ 3
				player.CameraMaxZoomDistance = math.max(0.5, startD + (0.5 - startD) * e)
				cam.FieldOfView = baseFov + math.sin(math.pi * a) * 10
				if a >= 1 then break end
				RunService.RenderStepped:Wait()
			end
			if tok == fpToken then
				cam.FieldOfView = baseFov
				player.CameraMaxZoomDistance = 0.5
				player.CameraMode = Enum.CameraMode.LockFirstPerson
			end
		end)
	else
		dotShow(false)
		player.CameraMode = ORIG_MODE
		player.CameraMaxZoomDistance = ORIG_MAX
		local target = math.clamp(12.5, ORIG_MIN, ORIG_MAX)
		task.spawn(function()
			local t0 = os.clock()
			while tok == fpToken do
				local a = dur <= 0 and 1 or math.clamp((os.clock() - t0) / dur, 0, 1)
				local e = 1 - (1 - a) ^ 3
				player.CameraMinZoomDistance = 0.5 + (target - 0.5) * e
				cam.FieldOfView = baseFov + math.sin(math.pi * a) * 6
				if a >= 1 then break end
				RunService.RenderStepped:Wait()
			end
			if tok == fpToken then
				cam.FieldOfView = baseFov
				player.CameraMinZoomDistance = ORIG_MIN
			end
		end)
	end
end

----------------------------------------------------------------
-- МУЗЫКА
----------------------------------------------------------------
local sound = new("Sound", { Name = "UmbrellaMusic", Volume = 0.5, Looped = true }, SoundService)
local currentId
local musicToken = 0
local statusLbl, lyricsBox, lyrStatusLbl
local statusKey, statusExtra = "m_enter_id", ""
local lyrN, lyrKey = 0, "l_none"
local lastLyric = nil
local activeLyrics = nil
local applyLyrics -- задаётся ниже

local function setStatus(key, extra)
	statusKey = key; statusExtra = extra or ""
	if statusLbl then statusLbl.Text = T(key) .. statusExtra end
end
local function setLyrStatus(n, key)
	lyrN = n; lyrKey = key
	if lyrStatusLbl then
		lyrStatusLbl.Text = (n > 0) and (T("l_lines") .. n .. "  ·  " .. T(key)) or T("l_none")
	end
end

local function loadMusic(raw)
	local id = tostring(raw or ""):match("%d+")
	if not id then setStatus("m_enter_id") return end
	musicToken += 1
	local tok = musicToken
	setStatus("m_loading")
	sound:Stop()
	currentId = nil
	sound.SoundId = "rbxassetid://" .. id
	sound.TimePosition = 0
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < 8 do
			local okLoaded, loaded = pcall(function() return sound.IsLoaded end)
			if okLoaded and loaded then break end
			task.wait(0.1)
		end
		if tok ~= musicToken then return end
		local okLoaded, loaded = pcall(function() return sound.IsLoaded end)
		if not okLoaded or not loaded then setStatus("m_failed") return end
		local name = "ID " .. id
		local okp, info = pcall(function() return MarketplaceService:GetProductInfo(tonumber(id)) end)
		if okp and info and info.Name then name = info.Name end
		if tok ~= musicToken then return end
		currentId = id
		lastLyric = nil
		sound.Looped = state.music_loop and true or false
		if not state.music_pause then sound:Play() end
		setStatus("m_playing", name)
		addLog("♪ " .. name)
		applyLyrics() -- пересчёт текста под длину трека
	end)
end

sound.DidLoop:Connect(function() lastLyric = nil end)

----------------------------------------------------------------
-- РАЗБОР ТЕКСТА (русский / English, LRC или просто строки)
----------------------------------------------------------------
local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

local function parseLyrics(text, duration)
	text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
	local timed, plain = {}, {}
	local anyTimed = false
	for raw in (text .. "\n"):gmatch("(.-)\n") do
		local ln = trim(raw)
		-- пропускаем теги вида [ar:Artist], [Припев], [Verse 1]
		if ln ~= "" and not ln:match("^%[%D*%]$") then
			local times, rest = {}, ln
			while true do
				local m, s, f, after = rest:match("^%[(%d+):(%d+)[%.:]?(%d*)%]%s*(.*)$")
				if not m then break end
				local t = tonumber(m) * 60 + tonumber(s) + ((f ~= "") and (tonumber("0." .. f) or 0) or 0)
				table.insert(times, t)
				rest = after
			end
			if #times == 0 then
				local m, s, after = rest:match("^(%d+):(%d%d)%s+(.+)$")
				if m then
					table.insert(times, tonumber(m) * 60 + tonumber(s))
					rest = after
				end
			end
			if #times > 0 then
				anyTimed = true
				for _, t in ipairs(times) do table.insert(timed, { t, trim(rest) }) end
			elseif anyTimed and #timed > 0 then
				-- строка без таймкода после строки с таймкодом - продолжение предыдущей
				local last = timed[#timed]
				last[2] = (last[2] ~= "" and (last[2] .. " ") or "") .. ln
			else
				table.insert(plain, ln)
			end
		end
	end
	if anyTimed then
		for i, e in ipairs(timed) do e[3] = i end
		table.sort(timed, function(a, b) if a[1] == b[1] then return a[3] < b[3] end return a[1] < b[1] end)
		return timed, "timed"
	end
	-- без таймкодов: равномерно по длине трека, с весом по длине строки
	local weights, total = {}, 0
	for i, l in ipairs(plain) do
		local w = math.max(utf8.len(l) or #l, 8) + 6
		weights[i] = w; total += w
	end
	local dur = (duration and duration > 1) and duration or math.max(#plain * 3, 120)
	local out, acc = {}, 0
	for i, l in ipairs(plain) do
		out[i] = { acc / total * dur, l }
		acc += weights[i]
	end
	return out, "auto"
end

----------------------------------------------------------------
-- 3D СУБТИТРЫ
----------------------------------------------------------------
local SUB_ANIMS = { { "type", "a_type" }, { "wave", "a_wave" }, { "fall", "a_fall" }, { "zoom", "a_zoom" }, { "spin", "a_spin" } }
local SUB_COLORS = {
	{ "pink", "k_pink" }, { "rainbow", "k_rainbow" }, { "neon", "k_neon" },
	{ "sunset", "k_sunset" }, { "ice", "k_ice" }, { "gold", "k_gold" },
}
local SUB_ALIGNS = { { "left", "a_left" }, { "center", "a_center" }, { "right", "a_right" } }
local SUB_FONT = Enum.Font.GothamBold
local SUB_SIZE, LINE_H = 60, 70

local subPart = new("Part", {
	Name = "UmbrellaSubtitles", Anchored = true, CanCollide = false, CanTouch = false, CanQuery = false,
	CastShadow = false, Transparency = 1, Size = Vector3.new(16, 4.5, 0.1),
}, nil)
local subGui = new("SurfaceGui", {
	Face = Enum.NormalId.Front, SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud, PixelsPerStud = 50,
	AlwaysOnTop = true, LightInfluence = 0, ResetOnSpawn = false,
}, subPart)
local subRoot = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, subGui)
local currentSet = nil
local subCF = nil

local function wrapText(text, maxc)
	local lines, cur = {}, ""
	for word in text:gmatch("%S+") do
		if #cur > 0 and (utf8.len(cur) or #cur) + 1 + (utf8.len(word) or #word) > maxc then
			table.insert(lines, cur); cur = word
		else
			cur = (#cur > 0) and (cur .. " " .. word) or word
		end
	end
	if #cur > 0 then table.insert(lines, cur) end
	return lines
end

local function colorFor(i, n, t)
	local name = state.subs_color
	if name == "rainbow" then return Color3.fromHSV((i / math.max(n, 1) + t * 0.15) % 1, 0.75, 1) end
	local a, b
	if name == "neon" then a, b = Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 200)
	elseif name == "sunset" then a, b = Color3.fromRGB(255, 170, 60), Color3.fromRGB(200, 60, 170)
	elseif name == "ice" then a, b = Color3.fromRGB(230, 250, 255), Color3.fromRGB(90, 170, 255)
	elseif name == "gold" then a, b = Color3.fromRGB(255, 220, 100), Color3.fromRGB(255, 150, 30)
	else a, b = Color3.fromRGB(255, 170, 205), C.accent end
	local ph = (i / math.max(n, 1) + t * 0.35) % 1
	local k = 1 - math.abs(2 * ph - 1)
	return a:Lerp(b, k)
end

local function stween(obj, props, time, style, dir, delay)
	delay = delay * animMul; time = time * animMul
	task.delay(delay, function()
		if obj.Parent then
			TS:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
		end
	end)
end

local function buildSet(text)
	local set = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, subRoot)
	local lines = wrapText(text, 24)
	while #lines > 3 do table.remove(lines) end
	local lineData, maxW, n = {}, 0, 0
	for li, ln in ipairs(lines) do
		local chars, total = {}, 0
		for _, cp in utf8.codes(ln) do
			local ch = utf8.char(cp)
			local w = (ch == " ") and SUB_SIZE * 0.3 or TextService:GetTextSize(ch, SUB_SIZE, SUB_FONT, Vector2.new(1000, 1000)).X
			table.insert(chars, { ch = ch, w = w + 2 })
			total += w + 2
		end
		lineData[li] = { chars = chars, total = total }
		maxW = math.max(maxW, total)
		n += #chars
	end
	local s = math.min(1, 760 / math.max(maxW, 1))
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
	}, set)
	new("UIScale", { Scale = s }, holder)
	local half = 370 / s
	local align = state.subs_align or "center"
	local letters, i = {}, 0
	for li, ld in ipairs(lineData) do
		local x
		if align == "left" then x = -half
		elseif align == "right" then x = half - ld.total
		else x = -ld.total / 2 end
		local y = (li - (#lineData + 1) / 2) * LINE_H
		for _, c in ipairs(ld.chars) do
			i += 1
			if c.ch ~= " " then
				local wr = new("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(c.w, SUB_SIZE + 10),
					BackgroundTransparency = 1, Position = UDim2.new(0.5, x + c.w / 2, 0.5, y),
				}, holder)
				local lb = new("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1, Text = c.ch, Font = SUB_FONT, TextSize = SUB_SIZE,
					TextColor3 = Color3.new(1, 1, 1), TextTransparency = 1, TextStrokeTransparency = 1,
					TextStrokeColor3 = Color3.fromRGB(10, 10, 20),
				}, wr)
				local sc = new("UIScale", { Scale = 1 }, lb)
				table.insert(letters, { wr = wr, lb = lb, sc = sc, bx = x + c.w / 2, by = y, i = i })
			end
			x += c.w
		end
	end
	return { set = set, letters = letters, n = n }
end

local function animateIn(S)
	local mode = S.mode
	local show = { TextTransparency = 0, TextStrokeTransparency = 0.45 }
	for _, L in ipairs(S.letters) do
		local d = L.i
		if mode == "type" then
			L.sc.Scale = 1.8
			stween(L.lb, show, 0.15, nil, nil, d * 0.04)
			stween(L.sc, { Scale = 1 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, d * 0.04)
		elseif mode == "wave" then
			L.sc.Scale = 0
			stween(L.sc, { Scale = 1 }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, d * 0.035)
			stween(L.lb, show, 0.25, nil, nil, d * 0.035)
		elseif mode == "fall" then
			L.lb.Position = UDim2.new(0.5, 0, 0.5, -120)
			stween(L.lb, { Position = UDim2.fromScale(0.5, 0.5) }, 0.75, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, d * 0.04)
			stween(L.lb, show, 0.25, nil, nil, d * 0.04)
		elseif mode == "zoom" then
			L.sc.Scale = 3
			local dl = math.random() * 0.5
			stween(L.sc, { Scale = 1 }, 0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, dl)
			stween(L.lb, show, 0.4, nil, nil, dl)
		else -- spin
			L.sc.Scale = 0
			L.lb.Rotation = 220
			stween(L.sc, { Scale = 1 }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, d * 0.04)
			stween(L.lb, { Rotation = 0 }, 0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, d * 0.04)
			stween(L.lb, show, 0.3, nil, nil, d * 0.04)
		end
	end
end

local function exitSet(S)
	S.dead = true
	for _, L in ipairs(S.letters) do
		stween(L.lb, { TextTransparency = 1, TextStrokeTransparency = 1 }, 0.3, nil, nil, L.i * 0.012)
		stween(L.sc, { Scale = 0.5 }, 0.3, nil, nil, L.i * 0.012)
	end
	task.delay((#S.letters * 0.012 + 0.35) * animMul + 0.1, function() S.set:Destroy() end)
end

local function showSubtitle(text)
	if currentSet then exitSet(currentSet) end
	local S = buildSet(text)
	S.mode = state.subs_anim
	S.born = os.clock()
	currentSet = S
	animateIn(S)
end

local function clearSubtitle()
	if currentSet then exitSet(currentSet); currentSet = nil end
end

applyLyrics = function()
	lastLyric = nil
	clearSubtitle()
	local text = lyricsBox and lyricsBox.Text or ""
	if text:match("%S") then
		local okLoaded, loaded = pcall(function() return sound.IsLoaded end)
	local entries, mode = parseLyrics(text, (okLoaded and loaded) and sound.TimeLength or nil)
		activeLyrics = entries
		setLyrStatus(#entries, mode == "timed" and "l_timed" or "l_auto")
	else
		activeLyrics = currentId and LYRICS[currentId] or nil
		setLyrStatus(activeLyrics and #activeLyrics or 0, "l_timed")
	end
end

-- показываем ТОЛЬКО текст песни (никаких названий треков)
local function subsTick()
	if not state.subs then return end
	if not currentId or not sound.IsPlaying or not activeLyrics then
		if currentSet then clearSubtitle() end
		lastLyric = nil
		return
	end
	local pos = sound.TimePosition - (state.subs_offset or 0)
	local idx = nil
	for k, e in ipairs(activeLyrics) do
		if e[1] <= pos then idx = k else break end
	end
	if idx ~= lastLyric then
		lastLyric = idx
		local line = idx and activeLyrics[idx][2] or ""
		if line ~= "" then showSubtitle(line) else clearSubtitle() end
	end
end

RunService.RenderStepped:Connect(function(dt)
	if subPart.Parent then
		local cam = getCamera()
		local t = os.clock()
		local target = cam.CFrame * CFrame.new(0, -1.1, -9.5) * CFrame.Angles(0, math.pi, 0)
			* CFrame.Angles(math.sin(t * 0.9) * 0.035, math.cos(t * 0.7) * 0.05, 0)
		subCF = subCF and subCF:Lerp(target, 1 - math.exp(-dt * 7)) or target
		subPart.CFrame = subCF
		subsTick()
		local S = currentSet
		if S and not S.dead then
			local age = t - S.born
			for _, L in ipairs(S.letters) do
				L.lb.TextColor3 = colorFor(L.i, S.n, t)
				local dy = math.sin(t * 2 + L.i * 0.3) * 2
				if S.mode == "wave" then dy += math.sin(t * 3 + L.i * 0.5) * 8 * math.clamp(age / 1.2, 0, 1) end
				L.wr.Position = UDim2.new(0.5, L.bx, 0.5, L.by + dy)
			end
		end
	end
end)

----------------------------------------------------------------
-- ПРАВАЯ ПАНЕЛЬ (настройки)
----------------------------------------------------------------
local themes = {
	Color3.fromRGB(235, 64, 52), Color3.fromRGB(235, 80, 140), Color3.fromRGB(110, 110, 120),
	Color3.fromRGB(110, 160, 235), Color3.fromRGB(90, 200, 130), Color3.fromRGB(160, 110, 235),
}

local panelWrap, panelGroup = makeWindow(975, 0, 285, 545)
drag(new("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1 }, panelGroup), panelWrap)

do
	local b = card(panelGroup, "main", 12, 17, 261, 248)
	row(b, { first = true, key = "bind_menu", kind = "bind", default = Enum.KeyCode.Insert })
	row(b, { key = "bind_reload", kind = "bind", default = Enum.KeyCode.R })
	row(b, { key = "logs", kind = "toggle", default = false })
	row(b, { key = "island", kind = "toggle", default = true })
	row(b, { key = "lang", kind = "dropdown", options = { "ru", "en" }, default = "ru", h = 38 })
	slider(b, { key = "anim", min = 0, max = 250, default = 100, fmt = "%d%%", int = true })
end

do
	local b = card(panelGroup, "look", 12, 278, 261, 250)
	slider(b, { first = true, key = "blur", min = 0, max = 24, default = 0.3, fmt = "%.2f" })
	row(b, { key = "shadows", kind = "toggle", default = true })
	row(b, { key = "scale", kind = "dropdown", options = { "75", "100", "125", "150" }, default = "100", h = 38 })
	row(b, { key = "visuals", kind = "toggle", default = true })
	row(b, { key = "notif", kind = "toggle", default = true })

	defaults.theme = 2; state.theme = 2
	local tr = new("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1 }, b)
	new("Frame", { Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 0, 1), BackgroundColor3 = C.line }, tr)
	tl(tr, "theme", UDim2.fromOffset(10, 0), UDim2.fromOffset(50, 36), 14)
	local rings = {}
	for i, col in ipairs(themes) do
		local d = new("TextButton", {
			Position = UDim2.fromOffset(62 + (i - 1) * 20, 14), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = col,
		}, tr)
		tracked[d] = nil
		corner(d, 5)
		rings[i] = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5, Enabled = (i == 2) }, d)
		d.MouseButton1Click:Connect(function()
			ui.theme(i)
			change("theme", i)
		end)
	end
	regUI("theme", function(i)
		for k, r in ipairs(rings) do r.Enabled = (k == i) end
	end)
	labels.theme = "theme"
end

----------------------------------------------------------------
-- ГЛАВНОЕ ОКНО
----------------------------------------------------------------
local mainWrap, wg = makeWindow(107, 202, 740, 493)
drag(new("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1 }, wg), mainWrap)

local rail = new("Frame", { Size = UDim2.fromOffset(43, 493), BackgroundColor3 = C.rail }, wg)
logoIcon(rail, 8.5, 9)

local side = new("Frame", { Position = UDim2.fromOffset(43, 0), Size = UDim2.fromOffset(145, 493), BackgroundColor3 = C.side }, wg)
local sideTitle, sideTitleEntry = tl(side, "t_info", UDim2.fromOffset(15, 14), UDim2.new(1, -15, 0, 30), 15, C.text)
local sideList = new("Frame", { Position = UDim2.fromOffset(0, 64), Size = UDim2.fromOffset(145, 420), BackgroundTransparency = 1 }, side)
local sideBar = new("Frame", { Size = UDim2.fromOffset(2, 18), BackgroundColor3 = C.accent }, side)

tl(wg, "main", UDim2.fromOffset(196, 17), UDim2.fromOffset(60, 24), 14, C.dim)
txt(wg, "/", UDim2.fromOffset(262, 17), UDim2.fromOffset(10, 24), 14, C.dim)
local crumb, crumbEntry = tl(wg, "s_heroes", UDim2.fromOffset(278, 17), UDim2.fromOffset(200, 24), 14, C.accent)
makeIcon(wg, "panel", UDim2.fromOffset(500, 21), C.dim, C.bg)
makeIcon(wg, "cloud", UDim2.fromOffset(518, 21), C.dim, C.bg)
local searchF = new("Frame", { Position = UDim2.fromOffset(543, 19), Size = UDim2.fromOffset(188, 24), BackgroundColor3 = C.field }, wg)
corner(searchF, 3); stroke(searchF)
makeIcon(searchF, "search", UDim2.fromOffset(7, 4), C.text, C.field)
local searchBox = new("TextBox", {
	BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -32, 1, 0),
	PlaceholderText = T("search"), PlaceholderColor3 = C.dim, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
}, searchF)
table.insert(trList, { searchBox, "search", "PlaceholderText" })

local pages = {}
local function newPage(name)
	local f = new("Frame", { Position = UDim2.fromOffset(188, 0), Size = UDim2.fromOffset(552, 493), BackgroundTransparency = 1, Visible = false }, wg)
	pages[name] = f
	return f
end
local function showPage(name)
	for n, f in pairs(pages) do f.Visible = (n == name) end
end

local SHOW = { "Враги, Союзники", "Враги", "Союзники", "Все" }
local ALIGN = { "Справа", "Слева", "Сверху", "Снизу" }

do
	local p = newPage("empty")
	txt(p, "—", UDim2.fromOffset(0, 200), UDim2.fromOffset(552, 40), 28, C.off, Enum.TextXAlignment.Center)
end

do
	local p = newPage("heroes")
	local b = card(p, "c_items", 8, 56, 262, 172)
	row(b, { first = true, h = 36, key = "items_enable", lbl = "r_enable", ic = "check", kind = "toggle", default = true, gear = true })
	row(b, { h = 36, key = "items_settings", lbl = "r_settings", ic = "settings", kind = "gear" })
	row(b, { h = 36, key = "items_show", lbl = "r_showon", ic = "person", kind = "dropdown", options = SHOW, default = "Враги, Союзники", dw = 105 })
	row(b, { h = 36, key = "items_align", lbl = "r_align", ic = "align", kind = "dropdown", options = ALIGN, default = "Справа", dw = 105, gear = true })

	b = card(p, "c_skills", 281, 56, 262, 172)
	row(b, { first = true, h = 36, key = "skills_enable", lbl = "r_enable", ic = "check", kind = "toggle", default = true, gear = true })
	row(b, { h = 36, key = "skills_compact", lbl = "r_compact", ic = "dots", kind = "toggle", default = false })
	row(b, { h = 36, key = "skills_show", lbl = "r_showon", ic = "person", kind = "dropdown", options = SHOW, default = "Враги, Союзники", dw = 105 })
	row(b, { h = 36, key = "skills_align", lbl = "r_align", ic = "align", kind = "dropdown", options = ALIGN, default = "Сверху", dw = 105, gear = true })

	b = card(p, "c_mods", 8, 242, 262, 140)
	row(b, { first = true, h = 36, key = "mods_enable", lbl = "r_enable", ic = "check", kind = "toggle", default = true, gear = true })
	row(b, { h = 36, key = "mods_show", lbl = "r_showon", ic = "person", kind = "dropdown", options = { "Союзники, Свои", "Союзники", "Враги", "Все" }, default = "Союзники, Свои", dw = 105 })
	row(b, { h = 36, key = "mods_align", lbl = "r_align", ic = "align", kind = "dropdown", options = ALIGN, default = "Сверху", dw = 105, gear = true })

	b = card(p, "c_bars", 281, 242, 262, 140)
	row(b, { first = true, h = 36, key = "bars_enable", lbl = "r_enable", ic = "check", kind = "toggle", default = true })
	row(b, { h = 36, key = "bars_own", lbl = "r_ownbars", ic = "bar", kind = "dropdown", options = { "Здоровье", "Мана", "Оба" }, default = "Здоровье", dw = 105 })
	row(b, { h = 36, key = "bars_xp", lbl = "r_xp", ic = "xp", kind = "toggle", default = false, gear = true })

	b = card(p, "c_extra", 8, 395, 535, 76)
	slider(b, { first = true, key = "hover_radius", lbl = "r_hover", ic = "expand", min = 0, max = 1100, default = 472, fmt = "%dpx", int = true })
end

do
	local p = newPage("camera")
	local b = card(p, "c_cam", 8, 56, 262, 62)
	row(b, { first = true, key = "fp", ic = "eye", kind = "toggle", default = false })
end

-- скрипты: 3D музыка
do
	local p = newPage("music")
	local b = card(p, "c_music", 8, 56, 262, 212)

	local ir = new("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1 }, b)
	local field = new("Frame", { Position = UDim2.fromOffset(10, 9), Size = UDim2.new(1, -104, 0, 26), BackgroundColor3 = C.field }, ir)
	corner(field, 3)
	local fs = stroke(field)
	local idBox = new("TextBox", {
		Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 1, 0), BackgroundTransparency = 1,
		PlaceholderText = T("m_id"), PlaceholderColor3 = C.dim, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
	}, field)
	table.insert(trList, { idBox, "m_id", "PlaceholderText" })
	idBox.Focused:Connect(function() fs.Color = C.accent; track(fs, "Color") end)
	idBox.FocusLost:Connect(function(enter)
		fs.Color = C.line
		if enter then loadMusic(idBox.Text) end
	end)
	local enterBtn = button(ir, "m_enter", Vector2.new(1, 0), UDim2.new(1, -10, 0, 9), UDim2.fromOffset(78, 26), C.accent)
	enterBtn.MouseButton1Click:Connect(function() loadMusic(idBox.Text) end)

	local sr = new("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1 }, b)
	statusLbl = txt(sr, T("m_enter_id"), UDim2.fromOffset(10, 0), UDim2.new(1, -20, 1, 0), 12, C.dim)
	statusLbl.TextTruncate = Enum.TextTruncate.AtEnd

	row(b, { key = "music_pause", ic = "pause", kind = "toggle", default = false })
	row(b, { key = "music_loop", ic = "loop", kind = "toggle", default = true })
	slider(b, { key = "music_vol", ic = "volume", min = 0, max = 100, default = 50, fmt = "%d%%", int = true })

	b = card(p, "c_subs", 281, 56, 262, 244)
	row(b, { first = true, key = "subs", ic = "subs", kind = "toggle", default = false })
	row(b, { key = "subs_anim", ic = "wand", kind = "dropdown", options = SUB_ANIMS, default = "wave" })
	row(b, { key = "subs_color", ic = "brush", kind = "dropdown", options = SUB_COLORS, default = "rainbow" })
	row(b, { key = "subs_align", ic = "align", kind = "dropdown", options = SUB_ALIGNS, default = "center" })
	row(b, { key = "fp", ic = "eye", kind = "toggle", default = false })
	slider(b, { key = "subs_offset", ic = "anim", min = -10, max = 10, default = 0, fmt = "%+.1fs" })

	-- текст песни
	local lc = rawCard(p, "c_lyrics", 8, 312, 535, 170)
	local sf = new("ScrollingFrame", {
		Position = UDim2.fromOffset(10, 32), Size = UDim2.new(1, -20, 0, 90), BackgroundColor3 = C.field,
		ScrollBarThickness = 3, ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
	}, lc)
	corner(sf, 3)
	local lfs = stroke(sf)
	new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }, sf)
	lyricsBox = new("TextBox", {
		Size = UDim2.new(1, 0, 0, 76), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
		MultiLine = true, TextWrapped = true, ClearTextOnFocus = false, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		PlaceholderText = T("l_placeholder"), PlaceholderColor3 = C.dim,
	}, sf)
	table.insert(trList, { lyricsBox, "l_placeholder", "PlaceholderText" })
	lyricsBox.Focused:Connect(function() lfs.Color = C.accent; track(lfs, "Color") end)
	lyricsBox.FocusLost:Connect(function() lfs.Color = C.line end)

	lyrStatusLbl = txt(lc, T("l_none"), UDim2.fromOffset(10, 128), UDim2.new(1, -220, 0, 16), 12, C.text)
	tl(lc, "l_hint", UDim2.fromOffset(10, 145), UDim2.new(1, -220, 0, 16), 12, C.dim)

	local clr = button(lc, "l_clear", Vector2.new(1, 0), UDim2.new(1, -108, 0, 132), UDim2.fromOffset(86, 26), C.field)
	local apl = button(lc, "l_apply", Vector2.new(1, 0), UDim2.new(1, -10, 0, 132), UDim2.fromOffset(90, 26), C.accent)
	apl.MouseButton1Click:Connect(function()
		applyLyrics()
		if lyrN > 0 then
			addLog(T("c_lyrics") .. ": " .. lyrN)
			if state.notif then toast(T("c_lyrics") .. ": " .. T("l_lines") .. lyrN) end
		end
	end)
	clr.MouseButton1Click:Connect(function()
		lyricsBox.Text = ""
		applyLyrics()
	end)
end

----------------------------------------------------------------
-- Рейка и сайдбар
----------------------------------------------------------------
local TABS = {}
TABS[4] = {
	title = "t_info",
	items = {
		{ "plane", "s_agro", "empty" }, { "camera", "s_cam", "camera" }, { "align", "s_heroes", "heroes" },
		{ "panel", "s_infoov", "empty" }, { "notif", "s_notif", "empty" }, { "upcircle", "s_off", "empty" },
		{ "radius", "s_radius", "empty" }, { "eyeslash", "s_show", "empty" }, { "eye", "s_vis", "empty" },
		{ "drop", "s_help", "empty" },
	},
}
TABS[8] = { title = "t_scripts", items = { { "note", "s_music", "music" } } }

local railNames = { "star", "globe", "people", "image", "island", "wand", "tools", "note", "cloud" }
local railIcons = {}
local railSel = 4
local tabSel = { [4] = 3 }
local sideBtns = {}

local railBar = new("Frame", { Size = UDim2.fromOffset(2, 22), BackgroundColor3 = C.accent }, rail)
local railHi = new("Frame", { Size = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.fromRGB(26, 26, 36) }, rail)
corner(railHi, 6)

local function selectSide(i)
	local tab = TABS[railSel]
	if not tab then
		sideBar.Visible = false
		showPage("empty")
		crumbEntry[2] = "dash"; crumb.Text = T("dash")
		return
	end
	tabSel[railSel] = i
	sideBar.Visible = true
	sideBar.Position = UDim2.fromOffset(2, 64 + (i - 1) * 29.3 + 5.5)
	for k, bt in ipairs(sideBtns) do
		local sel = (k == i)
		bt.tx.TextColor3 = sel and C.accent or C.text
		bt.ic.set(sel and C.accent or C.dim)
	end
	local item = tab.items[i]
	crumbEntry[2] = item[2]; crumb.Text = T(item[2])
	showPage(item[3])
end

local function buildSidebar()
	sideList:ClearAllChildren()
	sideBtns = {}
	local tab = TABS[railSel]
	sideTitleEntry[2] = tab and tab.title or "main"
	sideTitle.Text = T(sideTitleEntry[2])
	if tab then
		for i, it in ipairs(tab.items) do
			local b = new("TextButton", {
				Position = UDim2.fromOffset(0, (i - 1) * 29.3 + 5), Size = UDim2.new(1, 0, 0, 29), BackgroundTransparency = 1,
			}, sideList)
			local ic = makeIcon(b, it[1], UDim2.fromOffset(14, 6.5), C.dim, C.side)
			local tx = tl(b, it[2], UDim2.fromOffset(40, 0), UDim2.new(1, -44, 1, 0), 14)
			tx.TextTruncate = Enum.TextTruncate.AtEnd
			sideBtns[i] = { ic = ic, tx = tx }
			b.MouseButton1Click:Connect(function() selectSide(i) end)
		end
	end
	selectSide(tabSel[railSel] or 1)
end

local function selectRail(i)
	railSel = i
	local y = 66 + (i - 1) * 37.5
	railBar.Position = UDim2.fromOffset(0, y + 4)
	railHi.Position = UDim2.fromOffset(7, y)
	for k, ic in ipairs(railIcons) do ic.set(k == i and C.text or C.dim) end
	buildSidebar()
end

for i, name in ipairs(railNames) do
	local b = new("TextButton", {
		Position = UDim2.fromOffset(7, 66 + (i - 1) * 37.5), Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1, ZIndex = 2,
	}, rail)
	railIcons[i] = makeIcon(b, name, UDim2.fromOffset(7, 7), C.dim, C.rail)
	b.MouseButton1Click:Connect(function() selectRail(i) end)
end
makeIcon(rail, "gear", UDim2.fromOffset(13.5, 457), C.dim, C.rail)

overlay = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, root)

----------------------------------------------------------------
-- Эффекты настроек
----------------------------------------------------------------
local fpAuto, autoChanging = false, false

local function refreshLang()
	for _, e in ipairs(trList) do
		if e[1].Parent then e[1][e[3] or "Text"] = T(e[2]) end
	end
	for _, f in ipairs(dropRefresh) do f() end
	setStatus(statusKey, statusExtra)
	setLyrStatus(lyrN, lyrKey)
	updateIsland()
end

effects.bind_menu = function() updateIsland() end
effects.bind_reload = function() updateIsland() end
effects.logs = function(v) logWrap.Visible = v end
effects.island = function(v) island.Visible = v end
effects.lang = function(v) curLang = v; refreshLang() end
effects.anim = function(v) animMul = v / 100 end
effects.blur = function() updateBlur() end
effects.visuals = function() updateBlur() end
effects.shadows = function(v)
	for _, w in ipairs(windows) do w.shadow.Visible = not v end
end
effects.scale = function(v)
	menuScale = (tonumber(v) or 100) / 100
	if open then tw(scale, { Scale = baseScale() }, 0.15) end
end
effects.theme = function(i) setTheme(themes[i]) end

effects.music_vol = function(v) sound.Volume = v / 100 end
effects.music_loop = function(v) sound.Looped = v end
effects.music_pause = function(v)
	if currentId then sound.Playing = not v end
end

effects.subs_anim = function() lastLyric = nil end
effects.subs_align = function() lastLyric = nil end -- пересобрать текущую строку с новым выравниванием

effects.fp = function(v)
	if not autoChanging then fpAuto = false end
	applyFP(v)
end
effects.subs = function(v)
	if v then
		subPart.Parent = getCamera()
		subCF = nil
		lastLyric = nil
		if not state.fp then
			autoChanging = true
			ui.fp(true)
			change("fp", true)
			autoChanging = false
			fpAuto = true
		end
	else
		clearSubtitle()
		task.delay(0.8, function()
			if not state.subs then subPart.Parent = nil end
		end)
		if fpAuto and state.fp then
			autoChanging = true
			ui.fp(false)
			change("fp", false)
			autoChanging = false
		end
		fpAuto = false
	end
end

----------------------------------------------------------------
-- Ввод
----------------------------------------------------------------
UIS.InputBegan:Connect(function(input, processed)
	if listening and input.UserInputType == Enum.UserInputType.Keyboard then
		local key = listening
		listening = nil
		if input.KeyCode ~= Enum.KeyCode.Escape then change(key, input.KeyCode) end
		ui[key](state[key])
		return
	end
	if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if input.KeyCode == state.bind_menu then
		setOpen(not open)
	elseif input.KeyCode == state.bind_reload and open then
		reload()
	end
end)

----------------------------------------------------------------
-- Старт
----------------------------------------------------------------
for k, v in pairs(defaults) do
	if effects[k] then effects[k](v) end
end
selectRail(4)

-- На ПК меню открывается только через INS. На телефоне добавляется кнопка.
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local mobileOpenButton
if isMobile then
	mobileOpenButton = new("TextButton", {
		Name = "MobileOpenButton",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -70),
		Size = UDim2.fromOffset(52, 52),
		BackgroundColor3 = C.accent,
		Text = "≡",
		TextSize = 25,
		TextColor3 = Color3.new(1, 1, 1),
		ZIndex = 1000,
	}, gui)
	corner(mobileOpenButton, 16)
	stroke(mobileOpenButton, Color3.fromRGB(255, 255, 255))
	mobileOpenButton.MouseButton1Click:Connect(function()
		setOpen(not open)
	end)
end

setOpen(false)
