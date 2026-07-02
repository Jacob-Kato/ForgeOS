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
    def fetch(self):
        try:
            self.current_instruction = self.memory[self.pc]
        except IndexError:
            print("Hardware Fault: PC out of bounds.")
            self.HALT()

    def decode(self):
        if not isinstance(self.current_instruction, list):
            print("Hardware Fault: Invalid Instruction Structure.")
            self.HALT()
            return
            
        try:
            self.decoded_opcode = self.current_instruction[0]
            self.decoded_arg1 = self.current_instruction[1] if len(self.current_instruction) > 1 else None
            self.decoded_arg2 = self.current_instruction[2] if len(self.current_instruction) > 2 else None
        except Exception:
            print("Hardware Fault: Instruction Unpacking Failed.")
            self.HALT()
            return

        if self.decoded_opcode == 0:
            self.LOAD()
        elif self.decoded_opcode == 1:
            self.ADD()
        elif self.decoded_opcode == 10:
            self.store(self.decoded_arg1, self.decoded_arg2)
        elif self.decoded_opcode == 11:
            self.HALT()
        else:
            print(f"Hardware Fault: Invalid Opcode ({self.decoded_opcode}).")
            self.HALT()

    def store(self,registers,address):
        self.memory[address] = self.registers[registers]

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



    def execute(self,program):
        self.loadProgram(program)
        while not self.halted:
            self.fetch()
            if not self.halted:
                self.decode()
            self.pc +=1 
        return




program = [[0,0,1],
           [0,1,2],
           [1,0,1],
           [10,0,7],
           [11]]

cpu = ForgeCPU()

cpu.loadProgram(program)
cpu.execute(program)
print(cpu.__dict__)
