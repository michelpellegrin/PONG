push= require 'push' --librería para hacer una pantalla virtual con menor resolucion

Class = require 'class'-- Necesitamos que incluyas archivo class.lua

require 'Paddle' --cargar clases
require 'Ball'

WINDOW_WIDTH =1280
WINODW_HEIGHT= 720


--Declarar nueva resolución de la pantalla
VIRTUAL_WIDTH = 432 --resolucion del juego viejo 
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	math.randomseed(os.time())-- Semilla de random con fecha para que siempre empiece de un numero diferente el random. 
	
	 --push: "del push vas a buscar"
	-- cargar una nueva fuente .ttf para usarla
	smallfont = love.graphics.newFont('font.ttf', 18)
	scorefont = love.graphics.newFont('font.ttf', 12)
	
	love.graphics.setFont(smallfont)

	push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT, WINDOW_WIDTH, WINODW_HEIGHT, {
	fullscreen=false, --no se puede hacer la pantalla grande
	resizable= false, --no se puede cambiar el tamaño de pantalla
	vsync= true
	})

	love.window.setMode(WINDOW_WIDTH, WINODW_HEIGHT, {
		fullscreen= false, 
		resizable= false, 
		vsync= true
	})

	--cargar imagen de trofeo
	trofeo = love.graphics.newImage("trofeo.png")


	--Declaracion e importacion de sonidos.
	--Sonido al iniciar el juego
	inicioSound = love.audio.newSource("inicio.mp3", "stream")
	--La pelotita choca con el paddle 
	sound1 = love.audio.newSource("good.mp3", "stream")
	--la pelotita choca con los bordes.
	sound2 = love.audio.newSource("rebotebordes.mp3", "stream")
	--un jugador gana.
	win = love.audio.newSource("winner.mp3", "stream")
	--un jugador pierde. 
	lose= love.audio.newSource("lose2.mp3", "stream")


	--Crear objetos de la clase Paddle e inicializarlos en la posicion inicial
	player1 = Paddle(10, 30, 10, 20)
	player2 = Paddle(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT-50, 10, 20)

	-- Crear objetos de la clase Ball e inicializarl la pelotita en la posicion inical. 
	ball= Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4, 4)
	
	--Inicializar el puntaje de cada jugador
	player1Score = 0
	player2Score = 0

	--Indicar a quien le toca la variable de inicializacion.
	servingPlayer = 1

	gameState = 'start'--para saber cuando a inicio el juego y cuando se debe mover la pelotita. 

end 

function love.update(dt)--funcion para interactuar con el tecaldo durante el juego. Dt funcion que indica cada cuato se acyualizan los frames
	
	if gameState == 'serve' then

		 if servingPlayer == 1 then
            ball.dx = math.random(-255, 255)
        else 
            ball.dx = -math.random(-255, 255)
        end
        ball.dy = math.random(-100, 100)

    elseif gameState == 'play' then

		--checar borde superior de la pantalla para que rebote hacia abajo.
		if ball.y <= 0 then
			ball.y = 0-- quedate en 0 y cambia la posicion.
			ball.dy = -ball.dy
			love.audio.play(sound2)
		end
		
		--checar borde inferior de la pantalla para que rebote hacia arriba.
		if ball.y >= VIRTUAL_HEIGHT - 4 then -- -4 para contar el tamaño de la pelotita
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy	
			love.audio.play(sound2)
		end

		--Si choca cambiar posicion de x y y.
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03--cambiar dirección de la pelotita cuando choque con el paddle, e incrementar la velocidad para subir de nivel.
			ball.x= player1.x + 5 -- 5 porque la pelotita mide 4.
			love.audio.play(sound1)

			if ball.dy < 0 then --si iba hacia arriba entonces...
				ball.dy = -math.random(10, 150) -- cambiar la dirección para que no sea muy monótono y no se regrese en la misma dirección.
			else
				ball.dy = math.random(10, 150)
			end 
		end

		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03--cambiar dirección de la pelotita cuando choque con el paddle, e incrementar la velocidad para subir de nivel.
			ball.x= player2.x - 4 -- 5 porque la pelotita mide 4.
			love.audio.play(sound1)

			if ball.dy < 0 then --si iba hacia arriba entonces...
				ball.dy = -math.random(10, 150) -- cambiar la dirección para que no sea muy monótono y no se regrese en la misma dirección.
			else
				ball.dy = math.random(10, 150)
			end 
		end
	end

	-- Ciclo para actualizar el score del jugador 2 
	if ball.x < 0 then 

		--sonido de perder
		love.audio.play(lose)

		player2Score = player2Score + 1
		servingPlayer = 1

		if player2Score == 5 then
           
            winningPlayer = 2
            love.audio.play(win)
            gameState = 'done'
            
        
        else
            gameState = 'serve'
        
        end
        ball:reset()

	end

	-- Ciclo para actualizar el score del jugador 1 
	if ball.x > VIRTUAL_WIDTH then 
		--lose sound
        love.audio.play(lose)

        player1Score = player1Score + 1
        servingPlayer = 2

        if player1Score == 5 then
            
            winningPlayer = 1
            love.audio.play(win)
            gameState = 'done'
            
        else
            gameState = 'serve'
        
        end
        ball:reset()
	end

	if love.keyboard.isDown('w') then
		--variable para guardar la coordenada en 'y' y sepamos en dodne esta la pelotita
		player1.dy = -PADDLE_SPEED
		
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else 
		player1.dy = 0 -- si no se presiona ninguna tecla, que no haya cambio.
	end

	--Botones para controlar el paddle de la derecha 
	if love.keyboard.isDown('up') then
		player2.dy= -PADDLE_SPEED
		
	elseif love.keyboard.isDown('down') then
		player2.dy= PADDLE_SPEED
	else 
		player2.dy= 0
	end

	if gameState == 'play' then
		ball:update(dt)
		
	end

	player1:update(dt)--player llame a la funcion update para que actualice la posicion del paddle.
	player2:update(dt)

end

function love.keypressed(key)
	
	if key =='escape' then
		love.event.quit()

	elseif key == 'enter' or key == 'return' then 
		if gameState == 'start' then -- Empieza el juego con un enter.
			love.audio.play(inicioSound)
			gameState = 'serve'  ---------------------Servicio
		
		elseif gameState=='serve' then
				gameState = 'play'

		elseif gameState =='done' then

			gameState = 'serve' -- Reinicia el juego. 

			ball:reset()
			
			player1:init(10, 30, 10, 20)
			player2:init(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT-50, 10, 20)

			player1Score = 0
			player2Score = 0

			if winningPlayer == 1 then
				servingPlayer =1
			else 
				servingPlayer =2
			end

		end
	end
end

function love.draw()
	
	push:apply("start")
	--recordar que en lua (0,0) es la esquina superior izquierda. 
	--setColor(red, green, blue, alpha)
    --love.graphics.setColor(0, 100, 0, 100)


    
	--love.graphics.setColor(255/255, 0/255, 128/255, 100)--ponerle color al titulo y paddles
	love.graphics.setFont(smallfont)-- cargar font para titulo



	
	if gameState == 'start' then
		love.graphics.printf('Hello welcome to Pong!', 0, 5, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "Enter to start"', 0, 125, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer)..' serve', 0, 5, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 125 , VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        --no message 
    elseif gameState == 'done' then
        love.graphics.printf('Player '..tostring(winningPlayer)..' wins!', 0, 5, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to start new game.', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.draw(trofeo,  VIRTUAL_WIDTH/2-100, VIRTUAL_HEIGHT/3)
	end 

	--score
	love.graphics.setColor(234/255, 137/255, 154/255, 100)
	love.graphics.setFont(scorefont)-- cargar font para score 
	love.graphics.printf('Score', 0, 50, VIRTUAL_WIDTH, 'center')
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2-50, VIRTUAL_HEIGHT/3)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2+30, VIRTUAL_HEIGHT/3)

	player1:render()
	player2:render()
	ball:render()


	push:apply("end")
	
end




