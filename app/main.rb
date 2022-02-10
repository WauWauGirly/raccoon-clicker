# frozen_string_literal: true

WIDTH = 1280
HEIGHT = 720
H_CIRCLE = 180
RAD = H_CIRCLE / 2
GRAVITY = -9.81
BOUNCINESS = 0.95
RACCOON_SIZE = 10
RACCOON_WIDTH = 19
RACCOON_HEIGHT = 16
FONT = '/fonts/shpinscher.ttf'
SNAKES = 10
TIME = 15

class State
  INTRO = 0
  COUNTDOWN = 1
  GAME = 2
  CREDITS = 3
end

def inside_sprite(mouse_x, mouse_y, size, x_position, y_position)
  inside_x = mouse_x > x_position && mouse_x < x_position + size
  inside_y = mouse_y > y_position && mouse_y < y_position + size

  inside_x && inside_y
end

def tick(args)

    if args.state.tick_count == 0
      args.audio[:my_audio] = {
        input: 'sounds/music/music.ogg',
        gain: 0.3,
        looping: true
      }
    end

  @args = args
  @state ||= State::INTRO

  case @state
  when State::INTRO
    intro
    @state = State::COUNTDOWN if @args.inputs.keyboard.key_down.space || @args.inputs.mouse.click
    @state = State::CREDITS if @args.inputs.keyboard.key_down.c
  when State::COUNTDOWN
    countdown
  when State::GAME
    game
  when State::CREDITS
    credits
  end
end

def draw_all_raccoons
  sin = Math.sin(@args.state.tick_count / 60)
  sin = sin.clamp(0, 1).ceil
  sin_2 = Math.sin(@args.state.tick_count / 2)
  sin *= sin_2
  draw_raccoon(0, 0, false, sin)
  draw_raccoon(0, HEIGHT - RACCOON_HEIGHT * RACCOON_SIZE, false, sin)
  draw_raccoon(WIDTH - RACCOON_WIDTH * RACCOON_SIZE, HEIGHT - RACCOON_HEIGHT * RACCOON_SIZE, true, sin)
  draw_raccoon(WIDTH - RACCOON_WIDTH * RACCOON_SIZE, 0, true, sin)
end

def credits
  draw_all_raccoons
  text = ['Code and Art by Lea (WauWauGirly)','Raccoon by Dodo','Music by Micah Young','With Help by lyniat']
  i = 0
  text.each do |t|
    @args.outputs.labels << [WIDTH / 2, HEIGHT - 150 - i * 100, t, 60, 1, 0, 0, 150, 255, FONT]
    i += 1
  end

  if @args.inputs.mouse.click || @args.inputs.keyboard.key_down.space || @args.inputs.keyboard.key_down.escape
    @state = State::INTRO
  end
end

def draw_raccoon(x, y, flip, angle)
  @args.outputs.sprites << {
    x: x,
    y: y,
    w: 19 * RACCOON_SIZE,
    h: 16 * RACCOON_SIZE,
    path: '/sprites/raccoon.png',
    flip_horizontally: flip,
    angle: angle,
    angle_anchor_x: 0.5,
    angle_anchor_y: 0.5
  }
end

def intro
  @args.outputs.sprites << [0, 0, WIDTH, HEIGHT, '/sprites/start_screen.png']
  draw_all_raccoons
  @args.outputs.labels << [640, 200, 'click space to start', 50, 1, 0, 0, 150, 255, FONT]
  @args.outputs.labels << [640, 120, 'or c for credits', 20, 1, 0, 0, 150, 255, FONT]
end

def countdown
  @args.outputs.sprites << [0, 0, 1280, 720, '/sprites/background.png']
  @args.outputs.sprites << [0, 0, 1280, 720, '/sprites/front.png']
  @args.outputs.sprites << [0, 0, WIDTH, HEIGHT, '/sprites/blank.png', 0, 127]

  @time_countdown ||= 3

  @time_countdown -= 1 / 60

  if @time_countdown < -2
    @time_countdown = -2
    @state = State::GAME
    init_animals
  end

  @args.outputs.labels << if @time_countdown >= 1
                            [640, 450, "COUNTDOWN: #{@time_countdown.round}s", 60, 1, 0, 0, 255, 255, FONT]
                          else
                            [640, 450, 'Click the Raccoon', 60, 1, 0, 0, 255, 255, FONT]
                          end
end

def init_animals
  @animals = []

  @points = 0

  @time = TIME

  @tap_wait_time = 3

  @game_over = false

  @size = H_CIRCLE

  @time_countdown = 3

  i = 0

  while i < SNAKES + 1
    animal = {}
    animal[:x_speed] = 5 + Random.rand(8)
    animal[:y_speed] = 0
    animal[:x_position] = WIDTH - 1250 + Random.rand(530)
    animal[:y_position] = HEIGHT - 90 - Random.rand(320)
    animal[:flip] = false
    if i == 0
      animal[:start_x] = 0
      animal[:enemy] = false
    else
      animal[:start_x] = 3
      animal[:enemy] = true
    end
    @animals << animal
    i += 1
  end
end

def draw_animal(i)

  @animals[i].y_speed += GRAVITY / 60
  @animals[i].x_position += @animals[i].x_speed #@x_speed
  @animals[i].y_position += @animals[i].y_speed

  if @animals[i].x_position.negative?
    @animals[i].x_position = 0
    # @x_speed = -@x_speed * BOUNCINESS
    @animals[i].x_speed = -@animals[i].x_speed * BOUNCINESS
  end

  if @animals[i].x_position > WIDTH - H_CIRCLE
    @animals[i].x_position = WIDTH - H_CIRCLE
    # @x_speed = -@x_speed * BOUNCINESS
    @animals[i].x_speed = -@animals[i].x_speed * BOUNCINESS
  end

  if @animals[i].y_position.negative?
    @animals[i].y_position = 0
    @animals[i].y_speed = -@animals[i].y_speed * BOUNCINESS
  end

  if @animals[i].x_speed.negative? # @x_speed.negative?
    @animals[i].flip = true
  else
    @animals[i].flip = false
  end

  mouse_x = @args.inputs.mouse.x
  mouse_y = @args.inputs.mouse.y

  inside = inside_sprite(mouse_x, mouse_y, @size, @animals[i].x_position, @animals[i].y_position)

  if @args.inputs.mouse.click && inside && !@game_over
    # @args.outputs.sounds << '/sounds/click.wav'
    @size /= 1.03
    if @animals[i].enemy == false
      @raccoon_clicked = true
    else
      @snake_clicked = true
    end
  end

  @args.outputs.sprites << {
    x: @animals[i].x_position,
    y: @animals[i].y_position,
    w: @size,
    h: @size,
    path: '/sprites/animations.png',
    source_x: ((@args.state.tick_count / 10).to_i % 3) * 16 + @animals[i].start_x * 16,
    source_y:  0,
    source_w: 16,
    source_h: 16,
    flip_horizontally: @animals[i].flip
  }
end

def game

  @raccoon_clicked = false
  @snake_clicked = false

  @args.outputs.sprites << [0, 0, 1280, 720, '/sprites/background.png']

  i = 0

  while i < SNAKES + 1
    draw_animal(i)
    i += 1
  end

  @args.outputs.sprites << [0, 0, 1280, 720, '/sprites/front.png']

  unless @game_over
    @args.outputs.sprites << [0, HEIGHT - 60, WIDTH, 60, '/sprites/blank.png', 0, 127]
  end

  if @snake_clicked
    @points -= 1
  elsif @raccoon_clicked
    @points += 1
  end

  @args.outputs.labels << [0, HEIGHT, "Points: #{@points}", 20, 0, 150, 0, 0, 255, FONT]

  @time -= 1 / 60

  if @time <= 0
    @time = 0
    @game_over = true
    @tap_wait_time -= 1 / 60
  end

  @args.outputs.labels << [WIDTH, HEIGHT, "Time: #{@time.round}s", 20, 2, 0, 150, 0, 255, FONT]

  if @game_over
    @args.outputs.sprites << [0, 0, WIDTH, HEIGHT, '/sprites/blank.png', 0, 127]
    @args.outputs.labels << [WIDTH / 2, 450, "YOU GOT #{@points} POINTS!", 60, 1, 0, 0, 150, 255, FONT]
    @state = State::INTRO if @args.inputs.keyboard.key_down.space || (@args.inputs.mouse.click && @tap_wait_time < 0)
  end

  @raccoon_clicked = false
  @snake_clicked = false
end
