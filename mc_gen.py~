class Instructions:

	def READ_FROM_MEM_TO_A(self, *address):
		address = int(address[0]) if address else input('Enter address to read from (0-255): ')
		return [0, address]

	def READ_FROM_MEM_TO_B(self, *address):
		address = int(address[0]) if address else input('Enter address to read from (0-255): ')
		return [1, address]

	def WRITE_FROM_A_TO_MEM(self, *address):
		address = int(address[0]) if address else input('Enter address to write to (0-255): ')
		return [2, address]

	def WRITE_FROM_B_TO_MEM(self, *address):
		address = int(address[0]) if address else input('Enter address to write to (0-255): ')
		return [3, address]

	def ALU_OPERATION_REG_A(self, *op_type):
		op_type = str(op_type[0]) if op_type else raw_input('Choose operation type (+, -, *, <<, >>, A+1, B+1, A-1, B-1, A==B, A>B, A<B: ')
		op_type = self.ALU_operations.get(op_type)
		return [op_type + 4]

	def ALU_OPERATION_REG_B(self, *op_type):
		op_type = str(op_type[0]) if op_type else raw_input('Choose operation type (+, -, *, <<, >>, A+1, B+1, A-1, B-1, A==B, A>B, A<B: ')
		op_type = self.ALU_operations.get(op_type)
		return [op_type + 5]

	def BREQ_ADDR(self, *address):
		address = int(address[0]) if address else input('Enter address to branch to (0-255): ')
		return [150, address]

	def BGTQ_ADDR(self, *address):
		address = int(address[0]) if address else input('Enter address to branch to (0-255): ')
		return [166, address]

	def BLTQ_ADDR(self, *address):
		address = int(address[0]) if address else input('Enter address to branch to (0-255): ')
		return [182, address]

	def GOTO_ADDR(self, *address):
		address = int(address[0]) if address else input('Enter address to branch to (0-255): ')
		return [7, address]

	def GOTO_IDLE(self):
		return [8]

	def FUNCTION_CALL_ADDR(self, *address):
		address = int(address[0]) if address else input('Enter address to branch to (0-255): ')
		return[9, address]

	def RETURN(self):
		return[10]

	def DEREFERENCE_A(self):
		return [11]

	def DEREFERENCE_B(self):
		return [12]

	switcher = {
		'READ_FROM_MEM_TO_A': READ_FROM_MEM_TO_A,
		'READ_FROM_MEM_TO_B': READ_FROM_MEM_TO_B,
		'WRITE_FROM_A_TO_MEM': WRITE_FROM_A_TO_MEM,
		'WRITE_FROM_B_TO_MEM': WRITE_FROM_B_TO_MEM,
		'ALU_OPERATION_REG_A': ALU_OPERATION_REG_A,
		'ALU_OPERATION_REG_B': ALU_OPERATION_REG_B,
		'BREQ_ADDR': BREQ_ADDR,
		'BGTQ_ADDR': BGTQ_ADDR,
		'BLTQ_ADDR': BLTQ_ADDR,
		'GOTO_ADDR': GOTO_ADDR,
		'GOTO_IDLE': GOTO_IDLE,
		'FUNCTION_CALL_ADDR': FUNCTION_CALL_ADDR,
		'RETURN': RETURN,
		'DEREFERENCE_A': DEREFERENCE_A,
		'DEREFERENCE_B': DEREFERENCE_B

	}

	ALU_operations = {
		'+': 0,
		'-': 1,
		'*': 2,
		'<<': 3,
		'>>': 4,
		'A+1': 5,
		'B+1': 6,
		'A-1': 7,
		'B-1': 8,
		'A==B':9,
		'A>B':10,
		'A<B':11
	}
	
class ReverseInstructions():
	reverse_instructions = ''
	
	switcher = {
		'0000': ('READ_FROM_MEM_TO_A', 2),
		'0001': ('READ_FROM_MEM_TO_B', 2),
		'0010': ('WRITE_FROM_A_TO_MEM', 2),
		'0011': ('WRITE_FROM_B_TO_MEM', 2),
		'0100': ('ALU_OPERATION_REG_A', 1),
		'0101': ('ALU_OPERATION_REG_B', 1),
		'0110': ('BREQ_ADDR', 2),
		'0110': ('BGTQ_ADDR', 2),
		'0110': ('BLTQ_ADDR', 2),
		'0111': ('GOTO_ADDR', 2),
		'1000': ('GOTO_IDLE', 1),
		'1001': ('FUNCTION_CALL_ADDR', 2),
		'1010': ('RETURN', 1),
		'1011': ('DEREFERENCE_A', 1),
		'1100': ('DEREFERENCE_B', 1),
		'1111': ('NOTHING', 1)

	}	
	
	def REVERSE_ENGINEER_INSTRUCTIONS(self, instructions):
		no_command = 0
		while no_command < 256:
			if no_command < 254:
				current_instruction = instructions[no_command]
				acronym, increment = self.switcher.get(current_instruction[4:8])
				if increment==2:
					acronym = '{},{}'.format(acronym, int(instructions[no_command+1], 2))
			else:
				acronym = instructions[no_command]
				increment = 1
			print acronym
			no_command+=increment

if __name__ == "__main__":
	no_command = 0
	filename = raw_input('Enter output file name: ')
	instructions = Instructions()
	possible_commands = list(instructions.switcher.keys())
	additional_commands = ['SET_INTERRUPT_RETURN_PLACE', 'END', 'READ_FROM_FILE', 'REVERSE_ENGINEER']
	possible_commands.extend(additional_commands)
	print possible_commands
	intructions = ['11111111' for i in range(256)]
	get_bin = lambda x, n: format(x, 'b').zfill(n)
	while(1):
		command = raw_input("Enter command: ")
		if command in possible_commands and no_command <= 255:
			if command not in additional_commands:
				try:
					machine_code = getattr(instructions, command)()
					for code in machine_code:
						code_to_write = str(get_bin(code, 8))
						intructions[no_command]=code_to_write
						no_command += 1
				except ValueError as e:
					print('Invalid command. Please try again')
					print(e)			
			elif command == 'SET_INTERRUPT_RETURN_PLACE':
				address = input('Enter address to return after interrupt: ')
				intructions[254]=str(get_bin(address, 8))
			elif command == 'END':
				file = open(filename, 'w+')
				file.truncate(0)
				file.write('\n'.join(intructions))
				file.close()		
				break
			elif command == 'READ_FROM_FILE':
				input_filename = raw_input('Enter input filename: ')
				input_file = open(input_filename, 'r')
				commands = [line.rstrip('\n') for line in input_file]
				for command in commands:
					current_command = command.split(',')
					argument = current_command[1] if len(current_command)==2 else None
					print argument, current_command[0]
					if argument:
						machine_code = getattr(instructions, current_command[0])(argument)
					else:
						machine_code = getattr(instructions, current_command[0])()
					print machine_code
					for code in machine_code:
						code_to_write = str(get_bin(code, 8))
						intructions[no_command]=code_to_write
						no_command += 1
			elif command == 'REVERSE_ENGINEER':
				instructions_filename = raw_input('Enter instructions filename: ')
				instructions_file = open(instructions_filename, 'r')
				commands = [line.rstrip('\n') for line in instructions_file]
				reverse_instructions = ReverseInstructions()
				reverse_instructions.REVERSE_ENGINEER_INSTRUCTIONS(commands)
				print 'Done'
				break
		elif command in possible_commands and no_command >255:
			print 'You have reached a limit of instructions'
			file = open(filename, 'w+')
			file.truncate(0)
			file.write('\n'.join(intructions))
			file.close()	
			break
		else: 
			print 'Unrecognised command. Please try again.'