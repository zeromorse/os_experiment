require_relative 'dispatcher'

pcb_arr = [
    Pcb.new(9, 3, 2, 3),
    Pcb.new(38, 3, -1, 0),
    Pcb.new(30, 6, -1, 0),
    Pcb.new(29, 3, -1, 0),
    Pcb.new(0, 4, -1, 0)
]

dispatcher = Dispatcher.new(pcb_arr)
dispatcher.run