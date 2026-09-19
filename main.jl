mutable struct Battery
    charge::Int64
    const capacity::Int64

    function Battery(charge::Int64, capacity::Int64)
        if charge < 0 || capacity < 0
            error("Battery's fields mustn't have negative values") 
        end

        if capacity < 1000
            error("Battery's capacity must be greater than 1000")
        end

        if charge > capacity
            error("Battery's charge mustn't be greater than Battery's capacity")
        end

        return new(charge, capacity)
    end
end

mutable struct Sensor{T<:Number}
    value::T
    const name::String
    const unit::String

    function Sensor(value::T, name::String, unit::String) where {T<:Number}
        normalized_name = titlecase(strip(name))
        normalized_unit = titlecase(strip(unit))

        if isempty(normalized_name)
            error("Sensor's name mustn't be empty")
        end

        if isempty(normalized_unit)
            error("Sensor's unit mustn't be empty")
        end

        return new{T}(value, normalized_name, normalized_unit)
    end
end

struct Vehicle{T<:Number, S<:Sensor}
    name::String
    battery::Battery
    position::Vector{T}
    orientation::Vector{T}
    sensors::Dict{String, S}

    function Vehicle(name::String, battery::Battery, position::Vector{T}, orientation::Vector{T}, sensors::Dict{String, S}) where {T<:Number} where {S<:Sensor}
        normalized_name = titlecase(strip(name))

        if isempty(normalized_name)
            error("Vehicle's name mustn't be empty")
        end

        if length(position) != 2
            error("Vehicle's X and Y coordinates for its position must be declared")
        end

        if length(orientation) != 2
            error("Vehicle's X and Y coordinates for its orientation must be declared")
        end

        if length(sensors) == 0
            error("Vehicle must have at least 1 sensor")
        end

        return new{T, S}(normalized_name, battery, position, orientation, sensors)
    end
end

function Vehicle(battery::Battery, position::Vector{T}, orientation::Vector{T}, sensors::Dict{String, S}) where {T<:Number} where {S<:Sensor}
    return Vehicle(
        "Anonymous_$(rand(1000000:10000000))",
        battery,
        position,
        orientation,
        sensors,
    )
end

function Vehicle(name::String, battery::Battery, sensors::Dict{String, S}) where {S<:Sensor}
    return Vehicle(
        name,
        battery,
        [0.0, 0.0],
        [0.0, 0.0],
        sensors,
    )
end

function Vehicle(battery::Battery, sensors::Dict{String, S}) where {S<:Sensor}
    return Vehicle(
        "Anonymous_$(rand(1000000:10000000))",
        battery,
        [0.0, 0.0],
        [0.0, 0.0],
        sensors,
    )
end

struct Robot
    vehicle::Vehicle
    tool::String

    function Robot(vehicle::Vehicle, tool::String)
        normalized_tool = titlecase(strip(tool))

        if isempty(normalized_tool)
            error("Robot's tool mustn't be empty")
        end

        return new(vehicle, normalized_tool)
    end
end

struct Rover
    vehicle::Vehicle
    traction::Float64

    function Rover(vehicle::Vehicle, traction::Float64)
        if isnegative(traction)
            error("Rover's traction mustn't have negative value")
        end

        return new(vehicle, traction)
    end
end

struct Drone
    vehicle::Vehicle
    max_altitude::Float64

    function Drone(vehicle::Vehicle, max_altitude::Float64)
        if isnegative(max_altitude)
            error("Drone's max altitude mustn't have negative value")
        end

        return new(vehicle, max_altitude)
    end
end

struct Landform
    name::String

    function Landform(name::String)
        normalized_name = titlecase(strip(name))

        if isempty(normalized_name)
            error("Landform's name mustn't be empty")
        end

        return new(normalized_name)
    end
end

struct Plain
    landform::Landform
end

struct RockyTerrain
    landform::Landform
end

struct Crater
    landform::Landform
end

function operate(robot::Robot, plain::Plain)
    println("$(uppercase(robot.vehicle.name)): Starting operation with $(robot.tool) in the plain: $(plain.landform.name)")
end

function operate(rover::Rover, plain::Plain)
    println("$(uppercase(rover.vehicle.name)): Starting operation with traction $(rover.traction) in the plain: $(plain.landform.name)")
end

function operate(rover::Rover, rocky_terrain::RockyTerrain)
    println("$(uppercase(rover.vehicle.name)): Starting operation with traction $(rover.traction) in the rocky terrain: $(rocky_terrain.landform.name)")
end

function operate(rover::Rover, crater::Crater)
    println("$(uppercase(rover.vehicle.name)): Starting operation with traction $(rover.traction) in the crater: $(crater.landform.name)")
end

function operate(drone::Drone, crater::Crater)
    println("$(uppercase(drone.vehicle.name)): Starting operation at maximum altitude $(drone.max_altitude) in the crater: $(crater.landform.name)")
end

atlas_battery = Battery(2000, 5000)
atlas_temperature = Sensor(24.5, "Temperature", "°C")
atlas_sensors = Dict(
    "Temperature" => atlas_temperature
)

atlas_base = Vehicle(atlas_battery, atlas_sensors)
atlas = Robot(atlas_base, "Drill")
atlas_base_location = Landform("North Valley")
atlas_location = Plain(atlas_base_location)

operate(atlas, atlas_location)