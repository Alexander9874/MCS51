library IEEE;
use IEEE.std_logic_1164.all;

entity MFR is
	port (
		-- NESSESSORY:

		x0: in BIT;
		x1: in BIT;
		x2: in BIT;
		x3: in BIT;

		z0: in BIT;
		z1: in BIT;
		z2: in BIT;
		z3: in BIT;

		SI0: in BIT;
		SI1: in BIT;

		Y0: in BIT;
		Y1: in BIT;
		Y2: in BIT;

		EN: in BIT;
		CLK: in BIT;
		CLR: in BIT;

		q0: buffer BIT;
		q1: buffer BIT;
		q2: buffer BIT;
		q3: buffer BIT;

		-- DEBUG

		ma7421_0: buffer BIT;
		ma7421_1: buffer BIT;
		ma7421_2: buffer BIT;
		ma7421_3: buffer BIT;

		i0: buffer BIT;
		i1: buffer BIT;
		i2: buffer BIT;
		i3: buffer BIT;

		sm2_0: buffer BIT;
		sm2_1: buffer BIT;

		nd0_0: buffer BIT;
		nd0_1: buffer BIT;
		nd0_2: buffer BIT;
		nd0_3: buffer BIT;

		c0m3_0: buffer BIT;
		c0m3_1: buffer BIT;
		c0m3_2: buffer BIT;
		c0m3_3: buffer BIT;

		cg1_0: buffer BIT;
		cg1_1: buffer BIT;
		cg1_2: buffer BIT;

		sm4_0: buffer BIT;
		sm4_1: buffer BIT;
		sm4_2: buffer BIT;
		sm4_3: buffer BIT
    );
end MFR;

architecture MFR_arch of MFR is
	signal s1: integer range 0 to 10;
	signal s2: integer range 0 to 15;
	signal s3: integer range 0 to 2;
	signal s4: integer range 0 to 3;
	signal s5: integer range 0 to 9;
	signal s6: integer range 0 to 4;
	signal s7: integer range 0 to 14;

-- mod 10 & to 7421
COMPONENT MA7421
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;

		F: out integer range 0 to 10
	);
end COMPONENT;

-- sum 2 int
COMPONENT SM4
	PORT (
		A: in integer range 0 to 9;
		B: in integer range 0 to 4;
		S: out integer range 0 to 14
	);
end COMPONENT;

-- count ones in the first group from right
COMPONENT CG1
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;

		F: out integer range 0 to 4
	);
end COMPONENT;

-- count zeros and multiply by 3
COMPONENT C0M3
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;

		F: out integer range 0 to 9
	);
end COMPONENT;

-- count double zeros
COMPONENT CD0
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;

		F: out integer range 0 to 3
	);
end COMPONENT;

-- implimentation
COMPONENT IMPL
	PORT (
		A0: in BIT;
		A1: in BIT;
		A2: in BIT;
		A3: in BIT;

		B0: in BIT;
		B1: in BIT;
		B2: in BIT;
		B3: in BIT;

		F: out integer range 0 to 15
	);
end COMPONENT;

-- sum of 2 bits
COMPONENT SM2
	PORT (
		A0: in BIT;

		B0: in BIT;

		S: out integer range 0 to 2
	);
end COMPONENT;

-- register
COMPONENT RG
	PORT (
		-- NESSESSORY:

		SI0: in BIT;
		SI1: in BIT;

		Y0: in BIT;
		Y1: in BIT;
		Y2: in BIT;

		EN: in BIT;
		CLK: in BIT;
		CLR: in BIT;

		M0: in BIT;
		M1: in BIT;
		M2: in BIT;
		M3: in BIT;

		MA7421: in integer range 0 to 10;
		II: in integer range 0 to 15;
		SM2: in integer range 0 to 2;
		ND0: in integer range 0 to 3;
		SM4: in integer range 0 to 14;

		Q0: buffer BIT;
		Q1: buffer BIT;
		Q2: buffer BIT;
		Q3: buffer BIT;

		-- FOR DEBUG:

		C0M3: in integer range 0 to 9;
		CG1: in integer range 0 to 4;

		MA7421_0: buffer BIT;
		MA7421_1: buffer BIT;
		MA7421_2: buffer BIT;
		MA7421_3: buffer BIT;

		I0: buffer BIT;
		I1: buffer BIT;
		I2: buffer BIT;
		I3: buffer BIT;

		SM2_0: buffer BIT;
		SM2_1: buffer BIT;

		ND0_0: buffer BIT;
		ND0_1: buffer BIT;
		ND0_2: buffer BIT;
		ND0_3: buffer BIT;

		C0M3_0: buffer BIT;
		C0M3_1: buffer BIT;
		C0M3_2: buffer BIT;
		C0M3_3: buffer BIT;

		CG1_0: buffer BIT;
		CG1_1: buffer BIT;
		CG1_2: buffer BIT;

		SM4_0: buffer BIT;
		SM4_1: buffer BIT;
		SM4_2: buffer BIT;
		SM4_3: buffer BIT
	);
end COMPONENT;

Begin
	DD1: MA7421 
		PORT MAP (
			D0 => x0,
			D1 => x1,
			D2 => x2,
			D3 => x3,

			F => s1
		);

	DD2: IMPL 
		PORT MAP (
			A0 => x0,
			A1 => x1,
			A2 => x2,
			A3 => x3,

			B0 => z0,
			B1 => z1,
			B2 => z2,
			B3 => z3,

			F => s2
		);

	DD3: SM2 
		PORT MAP (
			A0 => x2,

			B0 => z1,

			S => s3
		);

	DD4: CD0 
		PORT MAP (
			D0 => x2,
			D1 => z1,
			D2 => x1,
			D3 => z0,

			F => s4
		);

	DD5: C0M3 
		PORT MAP (
			D0 => x0,
			D1 => x2,
			D2 => x3,

			F => s5
		);

	DD6: CG1 
		PORT MAP (
			D0 => z0,
			D1 => z1,
			D2 => z2,
			D3 => z3,

			F => s6
		);

	DD7: SM4
		PORT MAP (
			A => s5,
			B => s6,
			S => s7
		);

	DD8: RG
		PORT MAP (
			-- NESSESSORY:

			SI0 => SI0,
			SI1 => SI1,

			Y0 => Y0,
			Y1 => Y1,
			Y2 => Y2,

			EN => EN,
			CLK => CLK,
			CLR => CLR,

			M0 => Z0,
			M1 => Z1,
			M2 => Z2,
			M3 => Z3,

			MA7421 => s1,
			II => s2,
			SM2 => s3,
			ND0 => S4,
			SM4 => s7,

			Q0 => q0,
			Q1 => q1,
			Q2 => q2,
			Q3 => q3,

			-- FOR DEBUG:

			C0M3 => s5,
			CG1 => s6,

			MA7421_0 => ma7421_0,
			MA7421_1 => ma7421_1,
			MA7421_2 => ma7421_2,
			MA7421_3 => ma7421_3,

			I0 => i0,
			I1 => i1,
			I2 => i2,
			I3 => i3,

			SM2_0 => sm2_0,
			SM2_1 => sm2_1,

			ND0_0 => nd0_0,
			ND0_1 => nd0_1,
			ND0_2 => nd0_2,
			ND0_3 => nd0_3,

			C0M3_0 => c0m3_0,
			C0M3_1 => c0m3_1,
			C0M3_2 => c0m3_2,
			C0M3_3 => c0m3_3,

			CG1_0 => cg1_0,
			CG1_1 => cg1_1,
			CG1_2 => cg1_2,

			SM4_0 => sm4_0,
			SM4_1 => sm4_1,
			SM4_2 => sm4_2,
			SM4_3 => sm4_3
		);
end MFR_arch;


library IEEE;
use IEEE.std_logic_1164.all;

entity MA7421 is
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;

		F: out integer range 0 to 10
	);
end MA7421;

architecture MA7421_arch of MA7421 is
begin
	process (D0,D1,D2,D3)
	variable D: BIT_VECTOR (3 downto 0);
	begin
		D:= D3 & D2 & D1 & D0;
		case D is
			when "0000" => F <= 0;
			when "0001" => F <= 1;
			when "0010" => F <= 2;
			when "0011" => F <= 3;
			when "0100" => F <= 4;
			when "0101" => F <= 5;
			when "0110" => F <= 6;
			when "0111" => F <= 8;
			when "1000" => F <= 9;
			when "1001" => F <= 10;
			when "1010" => F <= 0;
			when "1011" => F <= 1;
			when "1100" => F <= 2;
			when "1101" => F <= 3;
			when "1110" => F <= 4;
			when "1111" => F <= 5;
		end case;
	end process;
end MA7421_arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IMPL is
	port (
		A0: in BIT;
		A1: in BIT;
		A2: in BIT;
		A3: in BIT;

		B0: in BIT;
		B1: in BIT;
		B2: in BIT;
		B3: in BIT;

		F: out integer range 0 to 15
	);
end entity IMPL;

architecture IMPL_arch of IMPL is
begin
	process(A0, A1, A2, A3, B0, B1, B2, B3)
		variable result_value: integer;
	begin
		result_value := 0;

		if (not A0 or B0) = '1' then
			result_value := result_value + 1;
		end if;

		if (not A1 or B1) = '1' then
			result_value := result_value + 2;
		end if;

		if (not A2 or B2) = '1' then
			result_value := result_value + 4;
		end if;

		if (not A3 or B3) = '1' then
			result_value := result_value + 8;
		end if;

		F <= result_value;
	end process;
end architecture IMPL_arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SM2 is
	port (
		A0: in BIT;

		B0: in BIT;

		S: out integer range 0 to 2
	);
end entity SM2;

architecture SM2_arch of SM2 is
begin
	process (A0,B0)
	variable D: BIT_VECTOR (1 downto 0);
	begin
		D:= A0 & B0;
		case D is
			when "00" => S <= 0;
			when "01" => S <= 1;
			when "10" => S <= 1;
			when "11" => S <= 2;
		end case;
	end process;
end SM2_arch;


library IEEE;
use IEEE.std_logic_1164.all;

entity CD0 is
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;

		F: out integer range 0 to 3
	);
end CD0;

architecture CD0_arch of CD0 is
begin
	process (D0,D1,D2,D3)
	variable D: BIT_VECTOR (3 downto 0);
	begin
		D:= D3 & D2 & D1 & D0;
		case D is
			when "0000" => F <= 3;
			when "0001" => F <= 2;
			when "0010" => F <= 1;
			when "0011" => F <= 1;
			when "0100" => F <= 1;
			when "0101" => F <= 0;
			when "0110" => F <= 0;
			when "0111" => F <= 0;
			when "1000" => F <= 2;
			when "1001" => F <= 1;
			when "1010" => F <= 0;
			when "1011" => F <= 0;
			when "1100" => F <= 1;
			when "1101" => F <= 0;
			when "1110" => F <= 0;
			when "1111" => F <= 0;
		end case;
	end process;
end CD0_arch;


library IEEE;
use IEEE.std_logic_1164.all;

entity C0M3 is
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;

		F: out integer range 0 to 9
	);
end C0M3;

architecture C0M3_arch of C0M3 is
begin
	process (D0,D1,D2)
	variable D: BIT_VECTOR (2 downto 0);
	begin
		D:= D2 & D1 & D0;
		case D is
			when "000" => F <= 9;
			when "001" => F <= 6;
			when "010" => F <= 6;
			when "011" => F <= 3;
			when "100" => F <= 6;
			when "101" => F <= 3;
			when "110" => F <= 3;
			when "111" => F <= 0;
		end case;
	end process;
end C0M3_arch;


library IEEE;
use IEEE.std_logic_1164.all;

entity CG1 is
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;

		F: out integer range 0 to 4
	);
end CG1;

architecture CG1_arch of CG1 is
begin
	process (D0,D1,D2,D3)
	variable D: BIT_VECTOR (3 downto 0);
	begin
		D:= D3 & D2 & D1 & D0;
		case D is
			when "0000" => F <= 0;
			when "0001" => F <= 1;
			when "0010" => F <= 1;
			when "0011" => F <= 2;
			when "0100" => F <= 1;
			when "0101" => F <= 1;
			when "0110" => F <= 2;
			when "0111" => F <= 3;
			when "1000" => F <= 1;
			when "1001" => F <= 1;
			when "1010" => F <= 1;
			when "1011" => F <= 2;
			when "1100" => F <= 2;
			when "1101" => F <= 1;
			when "1110" => F <= 3;
			when "1111" => F <= 4;
		end case;
	end process;
end CG1_arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SM4 is
	PORT (
		A: in integer range 0 to 9;
		B: in integer range 0 to 4;
		S: out integer range 0 to 14
	);
end SM4;

architecture SM4_arch of SM4 is
begin
	process(A, B)
	begin
		S <= A + B + 1;
	end process;
end SM4_arch;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RG is
	PORT (
		-- NESSESSORY:

		SI0: in BIT;
		SI1: in BIT;

		Y0: in BIT;
		Y1: in BIT;
		Y2: in BIT;

		EN: in BIT;
		CLK: in BIT;
		CLR: in BIT;

		M0: in BIT;
		M1: in BIT;
		M2: in BIT;
		M3: in BIT;

		MA7421: in integer range 0 to 10;
		II: in integer range 0 to 15;
		SM2: in integer range 0 to 2;
		ND0: in integer range 0 to 3;
		SM4: in integer range 0 to 14;

		Q0: buffer BIT;
		Q1: buffer BIT;
		Q2: buffer BIT;
		Q3: buffer BIT;

		-- FOR DEBUG:

		C0M3: in integer range 0 to 9;
		CG1: in integer range 0 to 4;

		MA7421_0: buffer BIT;
		MA7421_1: buffer BIT;
		MA7421_2: buffer BIT;
		MA7421_3: buffer BIT;

		I0: buffer BIT;
		I1: buffer BIT;
		I2: buffer BIT;
		I3: buffer BIT;

		SM2_0: buffer BIT;
		SM2_1: buffer BIT;

		ND0_0: buffer BIT;
		ND0_1: buffer BIT;
		ND0_2: buffer BIT;
		ND0_3: buffer BIT;

		C0M3_0: buffer BIT;
		C0M3_1: buffer BIT;
		C0M3_2: buffer BIT;
		C0M3_3: buffer BIT;

		CG1_0: buffer BIT;
		CG1_1: buffer BIT;
		CG1_2: buffer BIT;

		SM4_0: buffer BIT;
		SM4_1: buffer BIT;
		SM4_2: buffer BIT;
		SM4_3: buffer BIT
	);
end entity RG;

architecture RG_arch of RG is
begin
	process(SI0, SI1, Y0, Y1, Y2, EN, CLK, CLR, M0, M1, M2, M3, MA7421, II, ND0, SM4, C0M3, CG1, SM2)
		variable binary_value_ma7421: std_logic_vector(3 downto 0);
		variable binary_value_i: std_logic_vector(3 downto 0);
		variable binary_value_nd0: std_logic_vector(3 downto 0);
		variable binary_value_sm4: std_logic_vector(3 downto 0);

		-- FOR DEBUG
		variable binary_value_c0m3: std_logic_vector(3 downto 0);
		variable binary_value_cg1: std_logic_vector(2 downto 0);
		variable binary_value_sm2: std_logic_vector(1 downto 0);
	begin
		binary_value_ma7421 := std_logic_vector(to_unsigned(MA7421, 4));
		binary_value_i := std_logic_vector(to_unsigned(II, 4));
		binary_value_nd0 := std_logic_vector(to_unsigned(ND0, 4));
		binary_value_sm4 := std_logic_vector(to_unsigned(SM4, 4));

		-- FOR DEBUG
		binary_value_c0m3 := std_logic_vector(to_unsigned(C0M3, 4));
		binary_value_cg1 := std_logic_vector(to_unsigned(CG1, 3));
		binary_value_sm2 := std_logic_vector(to_unsigned(SM2, 2));

		if clr = '1' then
			Q0 <= '0';
			Q1 <= '0';
			Q2 <= '0';
			Q3 <= '0';

		elsif EN = '0' then null;

		elsif CLK'event and CLK = '1' then
			if Y0 = '0' and Y1 = '0' and Y2 = '0' then
				if binary_value_ma7421(0) = '1' then Q0 <= '1'; else Q0 <= '0'; end if;
				if binary_value_ma7421(1) = '1' then Q1 <= '1'; else Q1 <= '0'; end if;
				if binary_value_ma7421(2) = '1' then Q2 <= '1'; else Q2 <= '0'; end if;
				if binary_value_ma7421(3) = '1' then Q3 <= '1'; else Q3 <= '0'; end if;

			elsif Y0 = '0' and Y1 = '0' and Y2 = '1' then
				case SM2 is
					when 0 => Q0 <= Q0;  Q1 <= Q1; Q2 <= Q2;  Q3 <= Q3;
					when 1 => Q0 <= Q1;  Q1 <= Q2; Q2 <= Q3;  Q3 <= SI0;
					when 2 => Q0 <= Q2;  Q1 <= Q3; Q2 <= SI0;  Q3 <= SI1;
				end case ;

			elsif Y0 = '0' and Y1 = '1' and Y2 = '0' then
				Q0 <= '0';
				Q1 <= Q0;
				Q2 <= Q1;
				Q3 <= Q3;

			elsif Y0 = '0' and Y1 = '1' and Y2 = '1' then
				Q0 <= Q0 and M0;
				Q1 <= Q1 and M1;
				Q2 <= Q2 and M2;
				Q3 <= Q3 and M3;

			elsif Y0 = '1' and Y1 = '0' and Y2 = '0' then
				if binary_value_nd0(0) = '1' then Q0 <= '1'; else Q0 <= '0'; end if;
				if binary_value_nd0(1) = '1' then Q1 <= '1'; else Q1 <= '0'; end if;
				if binary_value_nd0(2) = '1' then Q2 <= '1'; else Q2 <= '0'; end if;
				if binary_value_nd0(3) = '1' then Q3 <= '1'; else Q3 <= '0'; end if;

			elsif Y0 = '1' and Y1 = '0' and Y2 = '1' then
				if binary_value_i(0) = '1' then Q0 <= '1'; else Q0 <= '0'; end if;
				if binary_value_i(1) = '1' then Q1 <= '1'; else Q1 <= '0'; end if;
				if binary_value_i(2) = '1' then Q2 <= '1'; else Q2 <= '0'; end if;
				if binary_value_i(3) = '1' then Q3 <= '1'; else Q3 <= '0'; end if;

			elsif Y0 = '1' and Y1 = '1' then
				if binary_value_sm4(0) = '1' then Q0 <= '1'; else Q0 <= '0'; end if;
				if binary_value_sm4(1) = '1' then Q1 <= '1'; else Q1 <= '0'; end if;
				if binary_value_sm4(2) = '1' then Q2 <= '1'; else Q2 <= '0'; end if;
				if binary_value_sm4(3) = '1' then Q3 <= '1'; else Q3 <= '0'; end if;

			end if;
		end if;

		-- FOR DEBUG

		if binary_value_ma7421(0) = '1' then
			MA7421_0 <= '1';
		else
			MA7421_0 <= '0';
		end if;

		if binary_value_ma7421(1) = '1' then
			MA7421_1 <= '1';
		else
			MA7421_1 <= '0';
		end if;

		if binary_value_ma7421(2) = '1' then
			MA7421_2 <= '1';
		else
			MA7421_2 <= '0';
		end if;

		if binary_value_ma7421(3) = '1' then
			MA7421_3 <= '1';
		else
			MA7421_3 <= '0';
		end if;


		if binary_value_i(0) = '1' then
			I0 <= '1';
		else
			I0 <= '0';
		end if;

		if binary_value_i(1) = '1' then
			I1 <= '1';
		else
			I1 <= '0';
		end if;

		if binary_value_i(2) = '1' then
			I2 <= '1';
		else
			I2 <= '0';
		end if;

		if binary_value_i(3) = '1' then
			I3 <= '1';
		else
			I3 <= '0';
		end if;


		if binary_value_sm2(0) = '1' then
			SM2_0 <= '1';
		else
			SM2_0 <= '0';
		end if;

		if binary_value_sm2(1) = '1' then
			SM2_1 <= '1';
		else
			SM2_1 <= '0';
		end if;


		if binary_value_nd0(0) = '1' then
			ND0_0 <= '1';
		else
			ND0_0 <= '0';
		end if;

		if binary_value_nd0(1) = '1' then
			ND0_1 <= '1';
		else
			ND0_1 <= '0';
		end if;

		if binary_value_nd0(2) = '1' then
			ND0_2 <= '1';
		else
			ND0_2 <= '0';
		end if;

		if binary_value_nd0(3) = '1' then
			ND0_3 <= '1';
		else
			ND0_3 <= '0';
		end if;


		if binary_value_c0m3(0) = '1' then
			C0M3_0 <= '1';
		else
			C0M3_0 <= '0';
		end if;

		if binary_value_c0m3(1) = '1' then
			C0M3_1 <= '1';
		else
			C0M3_1 <= '0';
		end if;

		if binary_value_c0m3(2) = '1' then
			C0M3_2 <= '1';
		else
			C0M3_2 <= '0';
		end if;

		if binary_value_c0m3(3) = '1' then
			C0M3_3 <= '1';
		else
			C0M3_3 <= '0';
		end if;


		if binary_value_cg1(0) = '1' then
			CG1_0 <= '1';
		else
			CG1_0 <= '0';
		end if;

		if binary_value_cg1(1) = '1' then
			CG1_1 <= '1';
		else
			CG1_1 <= '0';
		end if;

		if binary_value_cg1(2) = '1' then
			CG1_2 <= '1';
		else
			CG1_2 <= '0';
		end if;


		if binary_value_sm4(0) = '1' then
			SM4_0 <= '1';
		else
			SM4_0 <= '0';
		end if;

		if binary_value_sm4(1) = '1' then
			SM4_1 <= '1';
		else
			SM4_1 <= '0';
		end if;

		if binary_value_sm4(2) = '1' then
			SM4_2 <= '1';
		else
			SM4_2 <= '0';
		end if;

		if binary_value_sm4(3) = '1' then
			SM4_3 <= '1';
		else
			SM4_3 <= '0';
		end if;
	end process;
end architecture RG_arch;