package project

import zd "0d/odin"
import "0d/odin/std"

main :: proc() {
    main_container_name, diagram_names := std.parse_command_line_args ()
    palette := std.initialize_component_palette (diagram_names, components_to_include_in_project)
    std.run_demo (&palette, main_container_name, diagram_names, start_function)
}

start_function :: proc (main_container : ^zd.Eh) {
    x := zd.new_datum_bang ()
    msg := zd.make_message("", x, zd.make_cause (main_container, nil) )
    main_container.handler(main_container, msg)
}


components_to_include_in_project :: proc (leaves: ^[dynamic]zd.Leaf_Template) {
    zd.append_leaf (leaves, zd.Leaf_Template { name = "Echo", instantiate = echo })
    zd.append_leaf (leaves, zd.Leaf_Template { name = "Sleep", instantiate = sleep })
}


echo :: proc (name: string, owner : ^zd.Eh) -> ^zd.Eh {
    handler :: proc (eh: ^zd.Eh, msg: ^zd.Message) {
	zd.send(eh=eh, port="", datum=msg.datum, causingMessage=nil)
    }
    instance_name := zd.gensym ("Echo")
    return zd.make_leaf (instance_name, owner, nil, handler)
}



SLEEPDELAY := 1000000

SleepInfo :: struct {
    counter : int,
    saved_message : ^zd.Message
}

sleep :: proc(name: string, owner : ^zd.Eh) -> ^zd.Eh {
    handler :: proc(eh: ^zd.Eh, message: ^zd.Message) {
	first_time :: proc (m: ^zd.Message) -> bool {
            return ! zd.is_tick (m)
	}
	info := &eh.instance_data.(SleepInfo)
	if first_time (message) {
            info.saved_message = message
            zd.set_active (eh) // tell engine to keep running this component with 'ticks'
	}
	count := info.counter
	count += 1
	if count >= SLEEPDELAY {
            zd.set_idle (eh) // tell engine that we're finally done
            zd.forward (eh=eh, port="", msg=info.saved_message)
            count = 0
	}
	info.counter = count
    }
    info := new (SleepInfo)
    info.counter = 0
    name_with_id := zd.gensym("sleep")
    eh :=  zd.make_leaf (name_with_id, owner, info^, handler)
    return eh
}





