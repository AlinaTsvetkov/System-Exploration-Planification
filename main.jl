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

mutable struct Vehicle{T<:Number, S<:Sensor}
    operations_completed::Int64
    const name::String
    const battery::Battery
    const position::Vector{T}
    const orientation::Vector{T}
    const sensors::Dict{String, S}

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

        return new{T, S}(0, normalized_name, battery, position, orientation, sensors)
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

function operate!(robot::Robot, plain::Plain)
    consume_energy!(robot.vehicle, 100)
    println("$(uppercase(robot.vehicle.name)): Starting operation with $(robot.tool) in the plain: $(plain.landform.name)")
    show_operation_completed_message(robot.vehicle)
end

function operate!(rover::Rover, plain::Plain)
    consume_energy!(rover.vehicle, 100)
    println("$(uppercase(rover.vehicle.name)): Starting operation with traction $(rover.traction) in the plain: $(plain.landform.name)")
    show_operation_completed_message(rover.vehicle)
end

function operate!(rover::Rover, rocky_terrain::RockyTerrain)
    consume_energy!(rover.vehicle, 200)
    println("$(uppercase(rover.vehicle.name)): Starting operation with traction $(rover.traction) in the rocky terrain: $(rocky_terrain.landform.name)")
    show_operation_completed_message(rover.vehicle)
end

function operate!(rover::Rover, crater::Crater)
    consume_energy!(rover.vehicle, 300)
    println("$(uppercase(rover.vehicle.name)): Starting operation with traction $(rover.traction) in the crater: $(crater.landform.name)")
    show_operation_completed_message(rover.vehicle)
end

function operate!(drone::Drone, crater::Crater)
    consume_energy!(drone.vehicle, 300)
    println("$(uppercase(drone.vehicle.name)): Starting operation at maximum altitude $(drone.max_altitude) in the crater: $(crater.landform.name)")
    show_operation_completed_message(drone.vehicle)
end

function consume_energy!(vehicle::Vehicle, energy_to_consume::Int64)
    if vehicle.battery.charge < energy_to_consume
        error("$(uppercase(vehicle.name)): I can't do this operation because I'm out of battery")
    end

    vehicle.battery.charge -= energy_to_consume
    vehicle.operations_completed += 1

    println("$(uppercase(vehicle.name)): I've consumed $(energy_to_consume) after doing the operation. Now my charge is: $(vehicle.battery.charge)/$(vehicle.battery.capacity)")
end

function charge_energy!(vehicle::Vehicle)
    if vehicle.battery.charge == vehicle.battery.capacity
        error("$(uppercase(vehicle.name)): I can't do this operation because my charge is full!")
    end

    sleep(1.5)
    
    vehicle.battery.charge = vehicle.battery.capacity
    println("$(uppercase(vehicle.name)): I've charged my battery again! Now my charge is: $(vehicle.battery.charge)/$(vehicle.battery.capacity)")
end

function show_operation_completed_message(vehicle::Vehicle)
    sleep(1.5)

    println("$(uppercase(vehicle.name)): I've finished the operation successfully!")
end

function show_operations_report(vehicles::Dict{String, T}) where {T<:Vehicle}
    print("\n========= MISSION REPORT =========\n\n")

    for vehicle in values(vehicles)
        print("""
        VEHICLE: $(vehicle.name)
        OPERATIONS COMPLETED: $(vehicle.operations_completed)
        REMAINING BATTERY: $(vehicle.battery.charge)
        BATTERY: CAPACITY: $(vehicle.battery.capacity)
        \n""")
    end
end


#ATLAS CONFIGURATION
atlas_battery = Battery(4500, 5000)
atlas_temperature = Sensor(24.5, "Temperature", "°C")
atlas_sensors = Dict(
    "Temperature" => atlas_temperature
)

atlas_base = Vehicle("Atlas", atlas_battery, atlas_sensors)
atlas = Robot(atlas_base, "Drill")
atlas_base_location = Landform("North Valley")
atlas_location = Plain(atlas_base_location)

operate!(atlas, atlas_location)

#FREYA CONFIGURATION

freya_battery = Battery(7000, 15000)
freya_temperature = Sensor(21.3, "Temperature", "°C")
freya_sensors = Dict(
    "Temperature" => freya_temperature
)

freya_base = Vehicle("Freya", freya_battery, freya_sensors)
freya = Rover(freya_base, 0.84)
freya_base_location = Landform("Diamond Crater")
freya_location = Crater(freya_base_location)

operate!(freya, freya_location)
charge_energy!(freya.vehicle)

#NYX CONFIGURATION

nyx_battery = Battery(3000, 3500)
nyx_temperature = Sensor(26.5, "Temperature", "°C")
nyx_sensors = Dict(
    "Temperature" => nyx_temperature
)

nyx_base = Vehicle("Nyx", nyx_battery, nyx_sensors)
nyx = Drone(nyx_base, 43.23)
nyx_base_location = Landform("Magma Crater")
nyx_location = Crater(nyx_base_location)

operate!(nyx, nyx_location)

#CONFIGURING DICTIONARY
vehicles = Dict(
    "Atlas" => atlas.vehicle,
    "Freya" => freya.vehicle,
    "Nyx" => nyx.vehicle,
)

show_operations_report(vehicles)