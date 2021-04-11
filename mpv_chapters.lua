--display chapter on osd and easily switch between chapters by click on title of chapter




--  !!!!!!!!!   'options'  is what??? this is a table huh! !!!!!!!!!!

--[[		-- need to change --
options = {
	16, -- font_size
	"00FFFF", --font_color
	1.0, --border_size
	"000000", --border_color
	"C27F1B"  --font_color_currentChapter
}
playinfo = {
	{}, --array    (chapters)
	'', -- int    (chaptercount)
	{}, --array(deprecated, use single assdraw instead)     (assinterface)
	'', --int     (currentChapter)
    false  -- (loaded)
}
--]]


use_u_style = true

options = {
	font_size = 40,		-- 16
	font_color = "00FFFF",
	border_size = 1.0,
	border_color = "000000",
	font_color_currentChapter = "C27F1B"
}

--[[font_config ={
	font_size = 40,
	border_color = "000000",
	border_size = 1.0,
	active_color = "C27F1B",
	inactive_color = "00FFFF",
	u_style = false
}--]]

playinfo = {
	chapters = {}, --array
	chaptercount = "", -- int
	assinterface = {}, --array(deprecated, use single assdraw instead)
	currentChapter = "", --int
    loaded = false
}







toggle_switch = false
-- assdraw = mp.create_osd_overlay()
assdraw = mp.create_osd_overlay("ass-events")
autohidedelay = mp.get_property_number("cursor-autohide")


function init()
	mp.msg.info("first message in init")
	playinfo.chapters = getChapters()
	playinfo.chaptercount = table_length(playinfo.chapters)    --??????????????? length  (done)
    if playinfo.chaptercount == 0 then
        return
    end
	while playinfo.chaptercount * options.font_size > 1000 / 1.5 do
		options.font_size = options.font_size - 1
	end
	-- table_length(playinfo.chapters)
	-- drawChapterList()
	playinfo.loaded = true
	mp.msg.info("init done")
end



function table_length( a_table )    --fully functional
	local count = 0
	-- print("input is:", a_table)
	-- print("<table start>")
	for k, v in pairs(a_table) do
		count = count + 1
		-- print(k, v)
	end
	-- print('count is:', count)
	return count
end


function getChapters()           --fully done, but additional feature time is not yet added (done)
	local chapterCount = mp.get_property("chapter-list/count")
	if chapterCount == 0 then
		return {}              --    ????????????????????????
	else
		local chaptersArray = {}
		-- mp.osd_message("total chapters" .. chapterCount)
		-- for index = 0, tonumber(index) < chapterCount, 1 do
		for index = 0, chapterCount - 1, 1 do
			-- local chapterTitle = mp.get_property_native("chapter-list/" .. tostring(index) .. "/title")
			local chapterTitle = mp.get_property_osd("chapter-list/" .. tostring(index) .. "/title")
			local chapterTime = mp.get_property_osd("chapter-list/" .. tostring(index) .. "/time")
			if chapterTitle ~= nil then         -- flow -> what if all chaper is nill?
			-- if chapterTitle ~= {} then
				-- chaptersArray.insert(chapterTitle)
				-- table.insert(chaptersArray, chapterTitle)
				table.insert(chaptersArray, '[' .. chapterTime .. "]  " .. chapterTitle)
				-- table.insert(chaptersArray, chapterTitle .. " (" .. chapterTime .. ")")
			end
			-- print("index(" .. index .. ") is:", chapterTitle .. "(" .. chapterTime .. ")")
		end
		return chaptersArray
	end
end

function drawChapterList()		--functional
	resY = 0
	resX = 0
	assdraw.data = ""
	function active( element, resX, resY )
		assdraw.data = assdraw.data .. "{\\pos(" .. resX .. ", " .. resY .. ")}"
		assdraw.data = assdraw.data .. "{\\bord" .. options.border_size .. "}"
		assdraw.data = assdraw.data .. "{\\3c&H" .. options.border_color .. "&}"
		assdraw.data = assdraw.data .. "{\\c&H" .. options.font_color_currentChapter .. "&}"
		assdraw.data = assdraw.data .. "{\\alpha&H00}"
		assdraw.data = assdraw.data .. "{\\fs" .. options.font_size .. "}"
		-- assdraw.data = assdraw.data .. '{\\fscx' .. tostring(options.font_size) .. '}'
		-- assdraw.data = assdraw.data .. '{\\fscy' .. tostring(options.font_size) .. '}'
		assdraw.data = assdraw.data .. "{\\p0}"
		assdraw.data = assdraw.data .. element
		assdraw.data = assdraw.data .. "\\N"
	end

	function inactive( element, resX, resY )
		assdraw.data = assdraw.data .. "{\\pos(" .. resX .. ", " .. resY .. ")}"
		assdraw.data = assdraw.data .. "{\\bord" .. options.border_size .. "}"
		assdraw.data = assdraw.data .. "{\\3c&H" .. options.border_color .. "&}"
		assdraw.data = assdraw.data .. "{\\c&H" .. options.font_color .. "&}"
		assdraw.data = assdraw.data .. "{\\alpha&H60}"
		assdraw.data = assdraw.data .. "{\\fs" .. options.font_size .. "}"
		-- assdraw.data = assdraw.data .. '{\\fscx' .. tostring(options.font_size) .. '}'
		-- assdraw.data = assdraw.data .. '{\\fscy' .. tostring(options.font_size) .. '}'
		assdraw.data = assdraw.data .. "{\\p0}"
		assdraw.data = assdraw.data .. element
		assdraw.data = assdraw.data .. "\\N"
	end

	function u_style( active, element, resX, resY )
		assdraw.data = assdraw.data .. "{\\pos(" .. resX .. ", " .. resY .. ")}"
		if active then
			assdraw.data = assdraw.data .. "{\\alpha&H00}"
			-- assdraw.data = assdraw.data .. '{\\fscx80}'
			-- assdraw.data = assdraw.data .. '{\\fscy80}'
		else
			assdraw.data = assdraw.data .. "{\\alpha&H60}"
			-- assdraw.data = assdraw.data .. '{\\fscx75}'
			-- assdraw.data = assdraw.data .. '{\\fscy75}'
		end
		assdraw.data = assdraw.data .. "{\\fs" .. options.font_size .. "}"
		assdraw.data = assdraw.data .. element
		assdraw.data = assdraw.data .. "\\N"
	end

	function final( a_table )
		for index , element in pairs(a_table) do
			index = index - 1
			if playinfo.currentChapter == index then		-- active
				if use_u_style then
					u_style(true, element, resX, resY)
				else
					active(element, resX, resY)
				end
			else
				if use_u_style then
					u_style(false, element, resX, resY)
				else
					inactive(element, resX, resY)
				end
			end

			resY = resY + options.font_size
		end
		
	end

	final(playinfo.chapters)




--[[					--commenting useless--



	function setPos(str, _X, _Y)
		str = str .. "{\\pos(" .. _X .. ", " .. _Y .. ")}"
		return str
	end
	function setborderSize(str)
		str = str .. "{\\bord" .. options.border_size .. "}"
		return str
	end
	function setborderColor(str)
		str = str .. "{\\3c&H" .. options.border_color .. "&}"
		return str
	end
	function setFontColor(str, index)
		if playinfo.currentChapter == index then
			_color = options.font_color_currentChapter
		else
			_color = options.font_color
		end
		str = str .. "{\\c&H" .. _color .. "&}"
		return str
	end
	function setFont(str)
		str = str .. "{\\fs" .. options.font_size .. "}"
		str = str .. "{\\alpha&H" .. '60' .. "}"
		-- str = str .. '{\\fscx' .. tostring(options.font_size) .. '}'
		-- str = str .. '{\\fscy' .. tostring(options.font_size) .. '}'
		return str
	end
	function setEndofmodifiers(str)
		-- str = str .. "{\\p0}"
		return str
	end
	function setEndofLine(str)
		str = str .. "\\N"
		return str
	end
	function _final( a_table )
		for index , element in pairs(a_table) do
			index = index - 1
			assdraw.data = setPos(assdraw.data, resX, resY)
			assdraw.data = setborderSize(assdraw.data)
			assdraw.data = setborderColor(assdraw.data)
			assdraw.data = setFontColor(assdraw.data, index)
			assdraw.data = setFont(assdraw.data)
			assdraw.data = setEndofmodifiers(assdraw.data)
			assdraw.data = assdraw.data .. element
			assdraw.data = "" .. setEndofLine(assdraw.data)
			-- assdraw.data.data = assdraw.data
			resY = resY + options.font_size
		end
		-- print("assdraw:", assdraw.data)
	end


	-- _final(playinfo.chapters)


	-- playinfo.chapters.forEach(function (element, index) {
	-- 	assdraw.data = setPos(assdraw.data, resX, resY);
	-- 	assdraw.data = setborderSize(assdraw.data);
	-- 	assdraw.data = setborderColor(assdraw.data);
	-- 	assdraw.data = setFontColor(assdraw.data, index);
	-- 	assdraw.data = setFont(assdraw.data);
	-- 	assdraw.data = setEndofmodifiers(assdraw.data);
	-- 	assdraw.data = assdraw.data + element;
	-- 	assdraw.data = setEndofLine(assdraw.data);
	-- 	assdraw.data.data = assdraw.data;
	-- 	resY += options.font_size;
	-- });


--]]

end



function toggleOverlay()       --functional
	-- mp.osd_message("TAB is pressed")
    if not playinfo.loaded then
        return
    end
	if not toggle_switch then
		drawChapterList()
		-- print("assdraw:", assdraw.data)
		assdraw:update()
		mp.set_property("cursor-autohide", "no")
		toggle_switch =  not toggle_switch
	else
		assdraw:remove()
		mp.set_property("cursor-autohide", autohidedelay)
		toggle_switch = not toggle_switch
	end
end

function onChapterChange()		-- functional
	playinfo.currentChapter = mp.get_property_native("chapter")
	-- print(playinfo.currentChapter)
	if playinfo.currentChapter ~= nil then
		drawChapterList()
	end
	if playinfo.currentChapter ~= nil and toggle_switch then
		assdraw:update()
	end
end

function pos2chapter(x, y, overallscale)
	local vectical = y / (options.font_size * overallscale)    -- ????????? (math!!!!!!)
    -- print("ch_cou:", playinfo.chaptercount)
    if vectical > playinfo.chaptercount then
        return nil
    end
	local intVectical = math.floor(vectical)        -- ???????????????????     done!
	-- intVectical = intVectical + 1
	-- print("vect:", intVectical)
	local lengthofTitleClicked = string.len(tostring(playinfo.chapters[intVectical]))
	-- local lengthofTitleClicked = playinfo.chapters[intVectical].length    --length !!!!!!!
	-- print(playinfo.chapters[intVectical])
	-- print("len:", lengthofTitleClicked)
	-- lengthofTitleClicked_px = (intVectical * options.font_size) / overallscale
	local lengthofTitleClicked_px = (lengthofTitleClicked * options.font_size) / ( 1.72 * overallscale )
	-- print("opts:",options.font_size, overallscale, lengthofTitleClicked_px)
	-- print("x:",x)
	if x < lengthofTitleClicked_px then
		return intVectical
	else
		return nil
	end
end

function getOverallScale()		--I guess functional
	-- return mp.get_osd_size().height / 720
	return mp.get_property("height") / 720
end

function onMBTN_LEFT()		-- functional
	--get mouse position
    if not playinfo.loaded then
        return
    end
	if toggle_switch then
		local overallscale = getOverallScale()
		local pos_x, pos_y = mp.get_mouse_pos()
		-- local pos = mp.get_property_native("mouse-pos/x")
		-- print("pos is:", posx, posy)
		local chapterClicked = pos2chapter(pos_x, pos_y, overallscale)
		-- print(overallscale, chapterClicked)
		if chapterClicked ~= nil then
			mp.set_property_native("chapter", chapterClicked)
		end
	end
end


mp.register_event("file-loaded", init)
mp.add_key_binding("TAB", "tab", toggleOverlay)
mp.add_key_binding("MBTN_LEFT", "mbtn_left", onMBTN_LEFT)
mp.observe_property("chapter", "number", onChapterChange)

