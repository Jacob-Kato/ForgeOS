class ForgeCPU:
    def __init__(self):
        self.registers = [0, 0]
        self.pc = 0
        self.memory = [0] * 64 
# i feel that it only fair that because we doubled the Opcode we should doubled memory
        self.flag_register = None
         
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
        self.flag_register = (self.registers[registerA] == self.registers[registerB])

    def jump(self,pos):
        self.pc = pos

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
                    if not self.flag_register: 
                        self.jump(self.decoded_arg1)
                        self.flag_register = None
                    self.flag_register = None

                elif action == 101:
                    self.HALT()
                else:
                    print(f"Hardware Fault: Invalid Opcode ({self.decoded_opcode}).")
                    self.HALT()
            for keyname in self.__dict__:
                print(f"{self.pc}:{keyname}->{self.__dict__[keyname]}")


            self.pc +=1 
        return


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

