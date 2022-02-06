WIDTH = 1280
HEIGHT = 720
H_CIRCLE = 180
RAD = H_CIRCLE / 2
GRAVITY = -9.81
BOUNCINESS = 0.9

def inside_sprite(mouse_x, mouse_y, size, x_position, y_position)

  inside_x = mouse_x > x_position && mouse_x < x_position + size
  inside_y = mouse_y > y_position && mouse_y < y_position + size

  inside_x && inside_y
end

def tick args

  @x_speed ||= 5
  @x_position ||= WIDTH - 1250
  @x_position = @x_position + @x_speed

  @y_speed ||= 0
  @y_speed = @y_speed + GRAVITY / 60
  @y_position ||= HEIGHT - 90
  @y_position = @y_position + @y_speed

  @points ||= 0

  @time ||= 5

  @game_over ||= false

  #if @y_position <= RAD
  #  @y_position = RAD
  #end

  if @x_position < 0
    @x_position = 0
    @x_speed = -@x_speed * BOUNCINESS
  end

  if @x_position > WIDTH - H_CIRCLE
    @x_position = WIDTH - H_CIRCLE
    @x_speed = -@x_speed * BOUNCINESS
  end

  if @y_position < 0
    @y_position = 0
    @y_speed = -@y_speed * BOUNCINESS
  end

  @size ||= H_CIRCLE

  mouse_x = args.inputs.mouse.x
  mouse_y = args.inputs.mouse.y

  inside = inside_sprite(mouse_x, mouse_y, @size, @x_position, @y_position)

  if args.inputs.mouse.click && inside && !@game_over
    @size /= 1.1
    @points += 1
  end

  args.outputs.sprites << [@x_position, @y_position, @size, @size, '/sprites/raccoon.png']

  args.outputs.labels << [0, HEIGHT, "Points: #{@points}", 10, 0, 150, 0, 0, 255]

  @time -= 1 / 60

  if @time < 0
    @time = 0
    @game_over = true
  end

  args.outputs.labels << [WIDTH, HEIGHT, "Time: #{@time.round}s", 10, 2, 0, 150, 0, 255]

  if @game_over
    args.outputs.labels << [WIDTH / 2, HEIGHT / 2, "YOU GOT #{@points} POINTS!", 30, 1, 0, 0, 150, 255]
  end

end
