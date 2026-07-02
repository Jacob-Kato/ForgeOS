class ForgeCPU:
    def __init__(self):
        self.registers = [0, 0]
        self.pc = 0
        self.memory = [0] * 8
         
        self.halted = False
        self.current_instruction = None
        self.decoded_opcode = None
        self.decoded_arg1 = None
        self.decoded_arg2 = None

    def loadProgram(self,program):
        for i in range(len(program)):
            self.memory[i] = program[i]
    def HALT(self):
        self.halted = True
    def decode(self):
        self.current_instruction = self.memory[self.pc]
        self.decoded_opcode = self.current_instruction[0]
        if self.decoded_opcode == 10:
            return
        if self.decoded_opcode != 0 and self.decoded_opcode != 1 and self.decoded_opcode != 10:
            raise Exception(f"Invalid opcode cpu cycle {self.pc}")
        self.decoded_arg1 = self.current_instruction[1]
        if self.decoded_arg1 != 0 and self.decoded_arg1 != 1:
            raise Exception(f"Invalid arg1  cpu cycle {self.pc}")
        self.decoded_arg2 = self.current_instruction[2]

    def LOAD(self):
        self.registers[self.decoded_arg1] = self.decoded_arg2


    def ADD(self):
        a = self.registers[self.decoded_arg1]
        b = self.registers[self.decoded_arg2]

        while b != 0:
            sum_without_carry = a ^ b

            carry = (a&b)<<1 
            a = sum_without_carry
            b = carry
        self.registers[0] = a 
        return a 



    def execute(self):
        self.decode()
        self.LOAD()
        self.pc +=1
        self.decode()
        self.LOAD()
        self.pc += 1 
        self.decode()
        self.ADD()
        self.pc +=1 
        self.decode()
        self.HALT()




program = [[0,0,1],
           [0,1,2],
           [1,0,1],
           [10]]

cpu = ForgeCPU()

cpu.loadProgram(program)
cpu.execute()
print(cpu.__dict__)
