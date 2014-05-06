local function main()
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	-- 方格的原点
	local mapPoint = CCPointMake(90, 200)
	local addNum = nil
	local label = {}
	local num = {}
	for i = 0, 15 do
		num[i] = 0
	end

	-- 打印数组
	local function printNum()
		for i = 3, 0, -1 do
			print(num[i * 4 ] .. " " .. num[i * 4 + 1] .. " " .. num[i * 4 + 2] .. " " .. num[i * 4 + 3])
		end
		print("")
	end

	-- 刷新数字标签
	local function refreshNum()
		for i = 0, 15 do
			if num[i] ~= 0 then
				label[i]:setString(string.format("%d", num[i]))
			else
				label[i]:setString("")
			end
		end
		printNum()
	end

	-- 随机空位置产生一个2
	local function randNum()
		if(addNum ~= true) then
			return
		end
		math.randomseed(os.time())
		local num0 = {}
		local j = 0
		for i = 0, 15 do
			if num[i] == 0 then
				num0[j] = i
				j = j + 1
			end
		end
		index = math.random(0, j - 1)
		num[num0[index]] = 2;
		refreshNum()
		addNum = false
	end

	-- 根据方向移动一个数字
	local function moveNum(i, j, dir)
		curNum = num[i * 4 + j]
		if(dir == 0) then
			if i == 3 then
				return true
			end
			upNum = num[(i + 1) * 4 + j]
			if(upNum == 0) then
				num[(i + 1) * 4 + j] = curNum
				num[i * 4 + j] = 0
				return false
			else
				if(curNum == upNum) then
					num[(i + 1) * 4 + j] = 2 * curNum
					num[i * 4 + j] = 0
				end
			end
		elseif(dir == 1) then
			if i == 0 then
				return true
			end
			downNum = num[(i - 1) * 4 + j]
			if(downNum == 0) then
				num[(i - 1) * 4 + j] = curNum
				num[i * 4 + j] = 0
				return false
			else
				if(curNum == downNum) then
					num[(i - 1) * 4 + j] = 2 * curNum
					num[i * 4 + j] = 0
				end
			end
		elseif(dir == 2) then
			if j == 0 then
				return true
			end
			leftNum = num[i * 4 + j - 1]
			if(leftNum == 0) then
				num[i * 4 + j - 1] = curNum
				num[i * 4 + j] = 0
				return false
			else
				if(curNum == leftNum) then
					num[(i * 4 + j - 1)] = 2 * curNum
					num[i * 4 + j] = 0
				end
			end
		elseif(dir == 3) then
			if j == 3 then
				return true
			end
			rightNum = num[i * 4 + j + 1]
			if(rightNum == 0) then
				num[i * 4 + j + 1] = curNum
				num[i * 4 + j] = 0
				return false
			else
				if(curNum == rightNum) then
					num[(i * 4 + j + 1)] = 2 * curNum
					num[i * 4 + j] = 0
				end
			end
		end
		return true
	end

	-- 显示数字移动的动画
	local function showMove(i, j, iNew, jNew)
		-- label[i * 4 + j]
		moveto = CCMoveTo:create(0.1, ccp(mapPoint.x + jNew * 100, mapPoint.y + iNew * 100))
		place = CCPlace:create(ccp(mapPoint.x + j * 100, mapPoint.y + i * 100))
		callbackFunc = CCCallFunc:create(randNum)
		arr = CCArray:create()
		arr:addObject(moveto)
		arr:addObject(place)
		arr:addObject(callbackFunc)
		seq = CCSequence:create(arr)
		label[i * 4 + j]:runAction(seq)
	end

	-- 根据方向移动地图
	local function moveMap(dir)
		if(dir == 0) then
			print("up")
			for i = 3, 0, -1 do
				for j = 0, 3 do
					-- 非0才移动
					if(num[i * 4 + j] ~= 0) then
						-- 上面是0，就循环上移
						local inc = 0
						while (moveNum(i + inc, j, dir) == false) do 
							inc = inc + 1
						end
						if(num[(i + inc) * 4 + j] ~= 0) then
							showMove(i, j, i + inc, j)
						else
							showMove(i, j, i + inc + 1, j)
						end
					end
				end
			end
		elseif(dir == 1) then
			print("down")
			for i = 0, 3 do
				for j = 0, 3 do
					if(num[i * 4 + j] ~= 0) then
						local inc = 0
						while(moveNum(i + inc, j, dir) == false) do
							inc = inc - 1
						end
						if(num[(i + inc) * 4 + j] ~= 0) then
							showMove(i, j, i + inc, j)
						else
							showMove(i, j, i + inc - 1, j)
						end
					end
				end
			end
		elseif(dir == 2) then
			print("left")
			for i = 0, 3 do
				for j = 0, 3 do 
					if(num[i * 4 + j] ~= 0) then
						local inc = 0
						while(moveNum(i, j + inc, dir) == false) do
							inc = inc - 1
						end
						if(num[i * 4 + j + inc] ~= 0) then
							showMove(i, j, i, j + inc)
						else
							showMove(i, j, i, j + inc - 1)
						end
					end
				end
			end
		elseif(dir == 3) then
			print("right")
			for i = 0, 3 do
				for j = 3, 0, -1 do
					if(num[i * 4 + j] ~= 0) then
						local inc = 0
						while(moveNum(i, j + inc, dir) == false) do
							inc = inc + 1
						end
						if(num[i * 4 + j + inc] ~= 0) then
							showMove(i, j, i, j + inc)
						else
							showMove(i, j, i, j + inc + 1)
						end
					end
				end
			end
		end
	end

	-- 创建游戏层
	local function createLayerGame()
		local layerGame = CCLayerColor:create(ccc4(255,255,255,255))
		-- 添加背景
		local bg = CCSprite:create()
		bg:setColor(ccc3(192, 255, 62))
		bg:setTextureRect(CCRectMake(0,0,450,450))
		--local sz = CCSize(400,400)
		--bg:setContentSize(CCSizeMake(400,400))
		bg:setPosition(winSize.width / 2, winSize.height / 2)
		
		--bg:setColor(ccBlue)
		layerGame:addChild(bg, 0)
		print(string.format("mapPoint: x = %d, y = %d", mapPoint.x, mapPoint.y))
		
		-- 数字标签初始化
		
		for i = 0, 3 do
			for j = 0, 3 do			
			--	label[i * 4 + j] = CCLabelBMFont:create("", "num_s.fnt")
				label[i * 4 + j] = CCLabelTTF:create("", "Kozuka Gothic Pro H", 45)
				label[i * 4 + j]:setColor(ccc3(33, 176, 75))
				label[i * 4 + j]:setPosition(mapPoint.x + j * 100, mapPoint.y + i * 100)
				layerGame:addChild(label[i* 4 + j], 1)
			end
		end

		-- 触摸事件的处理
		local touchBeginPoing = nil
		local processed = nil

		local function onTouchBegan(x, y)
			touchBeginPoint = {x = x, y = y}
			processed = false
			addNum = true
			return true
		end

		local function onTouchMoved(x, y)
			if(processed == false) then
				-- 处理方向
				x0 = x - touchBeginPoint.x
				y0 = y - touchBeginPoint.y
				if(math.abs(x0) > math.abs(y0)) then
					if(x0 > 0) then
						-- 右
						moveMap(3)
					else
						-- 左
						moveMap(2)
					end
				else
					if(y0 > 0) then
						-- 上
						moveMap(0)
					else
						-- 下
						moveMap(1)
					end
				end
				processed = true
			--	randNum()

			end
		end

		local function onTouchEnded(x, y)
			touchBeginPoint = nil
			processed = false
		end

		local function onTouch(eventType, x, y)
			if eventType == "began" then
				return onTouchBegan(x, y)
			elseif eventType == "moved" then
				return onTouchMoved(x, y)
			else
				return onTouchEnded(x, y)
			end
		end

		layerGame:registerScriptTouchHandler(onTouch)
		layerGame:setTouchEnabled(true)

		return layerGame
	end

	-- 游戏的初始化
	local function initGame()
		addNum = true
		randNum()
		addNum = true
		randNum()
	end

	-- 运行
	local sceneGame = CCScene:create()
	sceneGame:addChild(createLayerGame())
	CCDirector:sharedDirector():runWithScene(sceneGame)
	refreshNum()
	initGame()
end

main()