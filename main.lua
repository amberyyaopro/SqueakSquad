--load assets and initialize variables
function love.load()
love.window.setTitle("Squeak Squad")
target = {}
target.x = 300
target.y = 300
target.radius = 42
target.visible = true
target.stateTimer = 1
target.hit = false
target.hitTimer = 0

score = 0
timer = 0
gameTimer = 20 --game timer in seconds
gameState = "Menu" --"Playing" = playing, "Paused" = pause, "Menu" = main menu

gameFont =love.graphics.newFont(25)

sprites = {}
sprites.levelBG = love.graphics.newImage("sprites/levelBG.png")
sprites.target = love.graphics.newImage("sprites/target.png")
sprites.hiteffect = love.graphics.newImage("sprites/hiteffect.png")
sprites.crosshairs = love.graphics.newImage("sprites/crosshairs.png")
sprites.mainMenu = love.graphics.newImage("sprites/mainMenu.png")
sprites.continue = love.graphics.newImage("sprites/continue.png")
sprites.exit = love.graphics.newImage("sprites/exit.png")
sprites.start = love.graphics.newImage("sprites/start.png")
sprites.menu = love.graphics.newImage("sprites/menu.png")

--ui button
uiButton = {}
uiButton.start = {}
uiButton.start.x = love.graphics.getWidth()/2-80
uiButton.start.y = 245
uiButton.start.w= 160
uiButton.start.h= 45

uiButton.continue = {}
uiButton.continue.x = love.graphics.getWidth()/2-77.5
uiButton.continue.y = 245
uiButton.continue.w= 155
uiButton.continue.h= 42

uiButton.exitMenu = {}
uiButton.exitMenu.x = love.graphics.getWidth()/2-77.5     
uiButton.exitMenu.y = 345
uiButton.exitMenu.w= 155
uiButton.exitMenu.h= 42


--sound
sound = {}

sound.bgm = love.audio.newSource("audio/bgm.mp3", "stream")
sound.bgm:play()
sound.bgm:setLooping(true)

sound.buttonClick = love.audio.newSource("audio/buttonclick.mp3", "static")
sound.start = love.audio.newSource("audio/start.mp3", "static")

sound.hit1 = love.audio.newSource("audio/hitsound.mp3", "static")
sound.hit2 = love.audio.newSource("audio/hitsound3.mp3", "static")


love.mouse.setVisible(false)

end

----------------------------------------------
--------------------UPDATE--------------------
----------------------------------------------
--game loop, run 60 times per second
--dt = delta time, amount of time since last frame
function love.update(dt)
   
    if gameState == "Playing" then
        
        --Game timer
        if timer > 0 then
            timer = math.max(0, timer - dt)
        else
            gameState = "Menu"
        end
   
        --Whack-a-Mole state switching
        target.stateTimer = target.stateTimer - dt
        if target.stateTimer <= 0 then
            if target.visible then
                target.visible = false
                target.stateTimer = randomFloat(0.5, 1.5)
            else
                target.visible = true
                target.x = math.random(target.radius, love.graphics.getWidth()-target.radius)
                target.y = math.random(285, love.graphics.getHeight()-target.radius)
                target.stateTimer = randomFloat(0.55, 0.65)
            end
        end
    
        --hit effect logic
        target.hitTimer = target.hitTimer - dt
        if target.hitTimer <= 0 then
            target.hit = false
        end

    end
end


--visuals 
function love.draw()    
    if gameState == "Menu" then
        love.graphics.draw(sprites.mainMenu, 0, -200)
        love.graphics.draw(sprites.start, uiButton.start.x, uiButton.start.y)  
        love.graphics.draw(sprites.exit, uiButton.exitMenu.x, uiButton.exitMenu.y)  
        love.graphics.setColor(1,1,1)

    end


    if gameState == "Playing" or gameState == "Paused" then
        --background
        love.graphics.draw(sprites.levelBG, 0, -95)

        --text
        love.graphics.setColor(0,0,0)
        love.graphics.setFont(gameFont)
        love.graphics.print("score: " .. score, 10, 10)
        love.graphics.print("time: " .. math.ceil(timer), 500, 10)
        love.graphics.setColor(1,1,1)

        --target
        if target.visible then
            love.graphics.draw(sprites.target, target.x-target.radius+5, target.y-target.radius)
            --love.graphics.circle("line", target.x, target.y, target.radius)
        end

        --hit effect
        if target.hit then
            love.graphics.draw(sprites.hiteffect, target.x-target.radius+5, target.y-target.radius)
        end
    end
    
    if gameState == "Paused" then
        love.graphics.draw(sprites.continue, uiButton.continue.x, uiButton.continue.y)  
        love.graphics.draw(sprites.menu, uiButton.exitMenu.x, uiButton.exitMenu.y)  
        love.graphics.setColor(1,1,1)
    end
    --crosshairs
    love.graphics.draw(sprites.crosshairs, love.mouse.getX()-14, love.mouse.getY()-5)
end

--mouse input logic
function love.mousepressed(x, y, button, istouch, presses)
    --game is not running
    if gameState == "Menu" then    
        if button == 1 and isInsideRect(x, y, uiButton.start) then
            gameState = "Playing"
            score = 0
            timer = gameTimer
            sound.start:play()
        elseif button == 1 and isInsideRect(x, y, uiButton.exitMenu) then
            love.event.quit()
        end
    --game is running
    elseif gameState == "Playing" then
        if button == 1 and target.visible then
            local mouseToTarget = trigonometry(x, y, target.x, target.y)
            if mouseToTarget < target.radius then
                    score = score + 1
                    randomHitSound():play()
                    target.visible = false
                    target.stateTimer = randomFloat(0.5, 1.5)
                    target.hit = true
                    target.hitTimer = 0.5
                    
            end
        end
    end
   
    if gameState == "Paused" then
        if button == 1 and isInsideRect(x, y, uiButton.continue) then
            gameState = "Playing"
            sound.bgm:play()
            sound.buttonClick:play()
        elseif button == 1 and isInsideRect(x, y, uiButton.exitMenu) then
            gameState = "Menu"
            sound.bgm:play()
            sound.buttonClick:play()
        end
    end
            
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "Playing" then
            gameState = "Paused"
            sound.bgm:pause()
        end
    end
end

--tool functions
function trigonometry(x1,y1,x2,y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2) 
end
function isInsideRect(x, y, rect)
    return x >= rect.x 
       and x <= rect.x + rect.w 
       and y >= rect.y 
       and y <= rect.y + rect.h
end
function randomFloat(min,max)
    return min + math.random() * (max - min)
end

function randomHitSound()
    local hitSounds = {sound.hit1, sound.hit2}
    local randomIndex = math.random(1, #hitSounds)
    return hitSounds[randomIndex]
end