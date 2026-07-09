class ForgeCPU:
    def __init__(self):
        self.registers = [0, 0]
        self.pc = 0
        self.memory = [0] * 16 
# i feel that it only fair that because we doubled the Opcode we should doubled memory
        self.cache = None
         
        self.halted = False
        self.current_instruction = None
        self.decoded_opcode = None
        self.decoded_mode = None
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
            self.decoded_mode = self.current_instruction[3] if len(self.current_instruction) > 3 else None
        except Exception:
            print("Hardware Fault: Instruction Unpacking Failed.")
            self.HALT()
            return

        if self.decoded_opcode == 0:
            return 0
        elif self.decoded_opcode == 1:
            return 1 
        elif self.decoded_opcode == 10:
            return 10 
        elif self.decoded_opcode == 11:
            return 11
        elif self.decoded_opcode == 100:
            return 100
        elif self.decoded_opcode == 101:
            return 101
        else:
            print(f"Hardware Fault: Invalid Opcode ({self.decoded_opcode}).")
            self.HALT()

    def store(self,registers,address):
        self.memory[address] = self.registers[registers]

    def comp(self,registerA,registerB):
        self.cache = (registerA == registerB)

    def jump(self,pos):
        if self.cache:
            return True
        else:
            self.pc = pos
            return False

    def LOAD(self,mode=None):
        if mode:
            self.registers[self.decoded_arg2] = self.memory[self.decoded_arg1]
        else:
            self.registers[self.decoded_arg1] = self.decoded_arg2


    def ADD(self):
        a = self.registers[self.decoded_arg1]
        b = self.registers[self.decoded_arg2]

        while b != 0:
            sum_without_carry = a ^ b

            carry = (a&b)<<1 
            a = sum_without_carry
            b = carry
        self.registers[self.decoded_arg1] = a 
        return a 



    def execute(self,program):
        self.loadProgram(program)
        while not self.halted:
            self.fetch()
            if not self.halted:
                action = self.decode()
                if action == 0:
                    self.LOAD(self.decoded_mode)
                elif action == 1:
                    self.ADD()
                elif action == 10:
                    self.store(self.decoded_arg1,self.decoded_arg2)
                elif action == 11:
                    self.comp(self.decoded_arg1,self.decoded_arg2)
                elif action == 100:
                    if self.jump(self.decoded_arg1):
                        continue
                elif action == 101:
                    self.HALT()
                else:
                    print(f"Hardware Fault: Invalid Opcode ({self.decoded_opcode}).")
                    self.HALT()
            print(f"{self.pc}: {self.__dict__}\n")

            self.pc +=1 
        return



# Loop program 
# [0,1,2] load loop count into register two 
# [0,0,0] load current count into register one 
# theres a reason i do it this way beacuse when you preform the additon the result will be 
# put in register one
# [10,1,7] store the loop count into memory
# [0,1,1] load one into register two 
# [1,0,1] you increass the current count by one 
# so now register one holds the result to the additon
# [0,7,1,1] load the loop count back into register two 
# [100,0,1] this is assuming we have a comp Opcode to see if register one and two are the same 
# if they are not we jump back to instruction 3 
#
# it looks like we need two Opcode anyways because jumping back to an instruction can't be the same as comp 
# again how would the program know where to jump 
# maybe decod can look at the result of the comp than either call jump or keep the program going 
#
#assuming comp works like this 
# def (self, registerA,registerB):
#   self.register[registerA] = (registerA == registerB)
#   return




program = [[0,0,2],
           [0,1,3],
           [1,0,1],
           [10,0,7],
           [0,7,0,1],
           [11]]

cpu = ForgeCPU()

cpu.loadProgram(program)
cpu.execute(program)
print(cpu.__dict__)














#instructions 
# Opcode| R | Num/addr/undef    
#----------------------------
#LOAD |000| 0 |  00000     |
#----------------------------
#ADD  |001| 0 | 0 | 0000   |
#--------------------------- 
#STORE|010| 0 |  00000     |
#--------------------------- 
#COMP |011| 0 | 0 |00      |
#--------------------------- 
#JUMP |100| 00000          |
#--------------------------- 
#HALT |101|      000000    |
#--------------------------- 




