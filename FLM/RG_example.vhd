library IEEE;
use IEEE.std_logic_1164.all;

entity MFR is
	port (
		x0: in BIT;
		x1: in BIT;
		x2: in BIT;
		x3: in BIT;

		z0: in BIT;
		z1: in BIT;
		z2: in BIT;
		z3: in BIT;

		SI: in BIT;

		Y0: in BIT;
		Y1: in BIT;

		EN: in BIT;
		CLK: in BIT;
		CLR: in BIT;

		q0: buffer BIT;
		q1: buffer BIT;
		q2: buffer BIT;
		q3: buffer BIT
	);
end MFR;


architecture MFR_arch of MFR is
	signal s1: integer range 0 to 4;
	signal s2: integer range 0 to 4;
	signal s3: integer range 0 to 8;

COMPONENT POZ
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;
		F: out integer range 0 to 4
	);
end COMPONENT; 

COMPONENT SM
	PORT (
		A: in integer range 0 to 4;
		B: in integer range 0 to 4;
		S: out integer range 0 to 8
	);
end COMPONENT;

COMPONENT RG
	PORT (
		SI: in BIT;
		SMM: in integer range 0 to 8;
		D0: in BIT;
	 	D1: in BIT;
		D2: in BIT;
		D3: in BIT;
		Y0: in BIT;
		Y1: in BIT;
		EN: in BIT;
		CLK: in BIT;
		CLR: in BIT;
		Q0: buffer BIT;
		Q1: buffer BIT;
		Q2: buffer BIT;
		Q3: buffer BIT
	);
end COMPONENT;


Begin
	DD1: POZ
		PORT MAP (
			D0 =>x0,
			D1 =>x1,
			D2 =>x2,
			D3 =>x3,
			F => s1
		);

	DD2: POZ
		PORT MAP (
			D0 =>z0,
			D1 =>z1,
			D2 =>z2,
			D3 =>z3,
			F => s2
		);

	DD3: SM
		PORT MAP (
			A => s1,
			B=> s2,
			S => s3
		);

	DD4: RG
		PORT MAP (
			SI =>SI,
			SMM =>s3,
			D0 => z0,
			D1 => z1, 
			D2 => z2,
			D3 => z3,
			Y0 => Y0,
			Y1 => Y1,
			EN => EN,
			CLK => CLK, 
			CLR => CLR,
			Q0 => q0,
			Q1 => q1,
			Q2 => q2,
			Q3 => q3
		);
end MFR_arch;

library IEEE;
use IEEE.std_logic_1164.all;

entity POZ is
	PORT (
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;
		F: out integer range 0 to 4
	);
end POZ;

architecture RTY_arch of POZ is
begin
	process (D0,D1,D2,D3)
	variable D: BIT_VECTOR (3 downto 0);
	begin
		D:= D3 & D2 & D1 & D0;
		case D is
			when "0000" => F<= 0;
			when "0001" => F<= 1;
			when "0010" => F<= 1;
			when "0011" => F<= 2;
			when "0100" => F<= 1;
			when "0101" => F<= 2;
			when "0110" => F<= 2;
			when "0111" => F<= 3;
			when "1000" => F<= 1;
			when "1001" => F<= 2;
			when "1010" => F<= 2;
			when "1011" => F<= 3;
			when "1100" => F<= 2;
			when "1101" => F<= 3;
			when "1110" => F<= 3;
			when "1111" => F<= 4;
		end case;
	end process;
end RTY_arch;

library IEEE;
use IEEE.std_logic_1164.all;

entity SM is
	PORT (
		A: in integer range 0 to 4;
		B: in integer range 0 to 4;
		S: out integer range 0 to 8
	);
end SM;

architecture ADD_arch of SM is
begin 
	S <= A + B;
end ADD_arch;

library IEEE;
use IEEE.std_logic_1164.all;

entity RG is
	PORT (
		SI: in BIT;
		SMM: in integer range 0 to 8;
		D0: in BIT;
		D1: in BIT;
		D2: in BIT;
		D3: in BIT;
		Y0: in BIT;
		Y1: in BIT;
		EN: in BIT;
		CLK: in BIT;
		CLR: in BIT;
		Q0: buffer BIT;
		Q1: buffer BIT;
		Q2: buffer BIT;
		Q3: buffer BIT
	);
end RG;
architecture RG_arch of RG is
begin
	process (clk, clr, en)
	begin
		if clr = '1' then
			Q0 <= '0';
			Q1 <= '0';
			Q2 <= '0';
			Q3 <= '0';
		elsif EN = '0' then null;
		elsif CLK'event and CLK = '1' then
			if Y0 = '0' and Y1 = '0' then
				Q0 <= D0;
				Q1 <= D1;
				Q2 <= D2;
				Q3 <= D3;
			elsif Y0 = '0' and Y1 = '1' then
				Q0 <= SI;
				Q1 <= Q0;
				Q2 <= Q1;
				Q3 <= Q2;
			elsif Y0 = '1' and Y1 = '0' then
				Q0 <= '0';
				Q1 <= Q0;
				Q2 <= Q1;
			elsif Y0 = '1' and Y1 = '1' then
			 	case	SMM is
					when 0 => Q0 <= '0';  Q1 <= '0'; Q2 <= '0';  Q3 <= '0';
					when 1 => Q0 <= '1';  Q1 <= '0'; Q2 <= '0';  Q3 <= '0';
					when 2 => Q0 <= '0';  Q1 <= '1'; Q2 <= '0';  Q3 <= '0';
					when 3 => Q0 <= '1';  Q1 <= '1'; Q2 <= '0';  Q3 <= '0';
					when 4 => Q0 <= '0';  Q1 <= '0'; Q2 <= '1';  Q3 <= '0';
					when 5 => Q0 <= '1';  Q1 <= '0'; Q2 <= '1';  Q3 <= '0';
					when 6 => Q0 <= '0';  Q1 <= '1'; Q2 <= '1';  Q3 <= '0';
					when 7 => Q0 <= '1';  Q1 <= '1'; Q2 <= '1';  Q3 <= '0';
					when 8 => Q0 <= '0';  Q1 <= '0'; Q2 <= '0';  Q3 <= '1';
				end case ;
			end if;
		end if;
	end process;
end RG_arch;