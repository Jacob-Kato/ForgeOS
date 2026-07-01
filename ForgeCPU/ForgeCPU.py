class ForgeCPU:
    def __init__(self):
        self.registers = [0, 0]
        self.pc = 0
        self.memory = [0] * 256
         
        self.halted = False
        self.current_instruction = None
        self.decoded_opcode = None
        self.decoded_arg1 = None
        self.decoded_arg2 = None

    def loadProgram(self,program):
        for i in range(len(program)):
            self.memory[i] = program[i]

    def decode(self):
        self.current_instruction = self.memory[self.pc]
        self.decoded_opcode = self.current_instruction[0]
        print(self.decoded_opcode)
        if self.decoded_opcode != 0 or self.decoded_opcode != 1 or self.decoded_opcode != 10:
            raise Exception(f"Invalid opcode cpu cycle {self.pc}")
        self.decoded_arg1 = self.current_instruction[1]
        if self.decoded_arg1 != 0 or self.decoded_arg1 != 1:
            raise Exception(f"Invalid arg1  cpu cycle {self.pc}")
        self.decoded_arg2 = self.current_instruction[2]





program = [[0,0,1],
           [0,1,2],
           [1,0,1],
           [10]]

cpu = ForgeCPU()

cpu.loadProgram(program)
cpu.decode()
print(cpu.__dict__)
