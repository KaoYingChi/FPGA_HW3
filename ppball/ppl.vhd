----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:33:59 10/19/2022 
-- Design Name: 
-- Module Name:    ppl - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ppl is
    Port (
	 
			  CLK    :in std_logic;--�ɯ�
			  rst    :in std_logic;--���s
	   left_button :in std_logic;--�����s
	  right_button :in std_logic;--�k���s
		led_1       :out std_logic;--���ܥkLED1-8
		led_2       :out std_logic;
		led_3       :out std_logic;
		led_4       :out std_logic;
		led_5       :out std_logic;
		led_6       :out std_logic;
		led_7       :out std_logic;
		led_8       :out std_logic
	       );
end ppl;

architecture Behavioral of ppl is

   type STATE_TYPE_1 is (left,right);
   signal             state_1 : STATE_TYPE_1;--�����k��
   signal            left_win : std_logic;--��Ĺ
   signal           right_win : std_logic;--�kĹ	
	signal             cnt_1HZ : std_logic;--���W
   signal    point_lose_right : std_logic;--�k�|��
   signal     point_lose_left : std_logic;--���|��
	signal     point_lose_right_1 : std_logic;--�k�Ӧ���
	signal     point_lose_left_1 : std_logic;--���Ӧ���
   signal                 REG : std_logic_vector(7 downto 0);--LED_�����k��
	signal          left_score : std_logic_vector(3 downto 0);--������
	signal         right_score : std_logic_vector(3 downto 0);--�k����
	signal           led_eight : std_logic_vector(7 downto 0);--LED_8��
	signal             counter : integer range 0 to 100000000;--�p�ƾ�
begin
  
		
		
	
	
	win_player : process (rst,clk,left_score,right_score) -- ��Ӫ�
	   begin
		   if rst = '1' then
			   right_win <= '0';
				left_win <= '0';
			elsif clk'event and clk = '1' then
			   if left_score = "1001" then
				   left_win <= '1';
				else	
					left_win <= '0';
				end if;
				if right_score = "1001" then
				   right_win <= '1';
				else 
				   right_win <= '0';
				end if;
			end if;
		end process;
		
   
	point_add : process (rst,clk,point_lose_right,point_lose_left,state_1,left_win,right_win) --Ĺ���[1
	   begin
		   if rst = '1' then
			   left_score <= "0000";
				right_score <= "0000";
		   elsif clk'event and clk = '1' then
			   if counter = 1000 then
				   if point_lose_right = '1' or point_lose_right_1 = '1' then
					   left_score <= left_score + '1';
				   elsif point_lose_left = '1' or point_lose_left_1 = '1' then
					   right_score <= right_score + '1';
					elsif left_win = '1' or right_win = '1' then
					   right_score <= "0000";
						left_score <= "0000";
				   end if;
				end if;
		   end if;
		end process;
	
	lose_ball : process (clk,state_1,REG,rst) ---�骺�o�y
	   begin
		   if rst = '1' then
			   state_1 <= right;
		   elsif clk'event and clk = '1' then
			 if counter = 1000 then
			   if point_lose_right = '1' or point_lose_right_1 = '1' then
					state_1 <= left;
				elsif point_lose_left = '1' or point_lose_left_1 = '1' then
					state_1 <= right;
				end if;
			end if;
			end if;
		end process;
	



	right_button_touch : process (rst,clk,right_button,state_1,counter,REG) --�k�|�y 
		begin
		   if rst = '1' then
			   point_lose_right <= '0';
			elsif clk'event and clk = '1' then
				   if state_1 = left and REG = "00000001"  then  
				     point_lose_right <= '0';
					elsif REG = "00000000" and state_1 = right then --�k��P�_�y�S����
					   point_lose_right <= '1';
				   end if;
			end if;
		end process;
		
	right_button_touch_loss : process (rst,clk,right_button,state_1,counter,REG) --�k���s���U 
		begin
		   if rst = '1' then
			   point_lose_right_1 <= '0';
			elsif clk'event and clk = '1' then
			    if right_button = '1'  then
				    if REG /= "10000000" and state_1 = right then
					    point_lose_right_1 <= '1'; 
					 end if;
             elsif right_button = '0' then
				    if state_1 = left and REG = "00000001" then
                   point_lose_right_1 <= '0';	
                end if;	
             end if;					 
			end if;
		end process;
	
	
	
	left_button_touch : process (rst,clk,left_button,state_1) --���|�y
		begin
		   if rst = '1' then
			   point_lose_left <= '0';
			elsif clk'event and clk = '1' then
				if state_1 = right and REG = "10000000" then
					point_lose_left <= '0';
				elsif REG = "00000000" and state_1 <= left then --����P�_�y�S����
					point_lose_left <= '1';
				end if;

			end if;
		end process;
	
	left_button_touch_loss : process (rst,clk,left_button,state_1) --�����s���U
		begin
		   if rst = '1' then
			   point_lose_left_1 <= '0';
			elsif clk'event and clk = '1' then
			   if left_button = '1' then
				   if REG /= "00000001" and state_1 <= left then
					   point_lose_left_1 <= '1';
					end if;
		      elsif left_button = '0' then
				   if state_1 = right and REG = "10000000" then
				   point_lose_left_1 <= '0';
					end if;
				end if;
			end if;
		end process;
		
		
	
   led_tran : process (clk,led_eight,left_win,right_win)--LED�G�� 
	   begin
			if clk'event and clk = '1' then
			   if led_eight = "10000000" then
				   led_1 <= '1';
				else
				   led_1 <= '0';
					end if;
				if led_eight = "01000000" then
				   led_2 <= '1';
				else
				   led_2 <= '0';
					end if;
				if led_eight = "00100000" then
				   led_3 <= '1';
				else
				   led_3 <= '0';
					end if;
				if led_eight = "00010000" then
				   led_4 <= '1';
				else
				   led_4 <= '0';
					end if;
				if led_eight = "00001000" then
				   led_5 <= '1';
				else
				   led_5 <= '0';
					end if;
				if led_eight = "00000100" then
				   led_6 <= '1';
				else
				   led_6 <= '0';
					end if;
				if led_eight = "00000010" then
				   led_7 <= '1';
				else
				   led_7 <= '0';
					end if;
				if led_eight = "00000001" then
				   led_8 <= '1';
				else
				   led_8 <= '0';
					end if;
				if left_win = '1' then
				   led_1 <= '1';
					led_2 <= '1';
					led_3 <= '1';
					led_4 <= '1';
				elsif right_win = '1' then
				   led_5 <= '1';
					led_6 <= '1';
					led_7 <= '1';
					led_8 <= '1';
					end if;
					
			end if;

		end process;


   led_light : process (rst,clk,REG)--LED�G�t
	   begin
		   if rst = '1' then
			   led_eight <= "10000000";
		   elsif clk'event and clk = '1' then
			   if REG = "10000000" then
				   led_eight(7) <= '1';
				else
				   led_eight(7) <= '0';
				end if;
				if REG = "01000000" then
				   led_eight(6) <= '1';
				else
				   led_eight(6) <= '0';
				end if;
				if REG = "00100000" then
				   led_eight(5) <= '1';
				else
				   led_eight(5) <= '0';
				end if;
				if REG = "00010000" then
				   led_eight(4) <= '1';
				else
				   led_eight(4) <= '0';
				end if;
            if REG = "00001000" then
				   led_eight(3) <= '1';
				else
				   led_eight(3) <= '0';
				end if;
            if REG = "00000100" then
				   led_eight(2) <= '1';
				else
				   led_eight(2) <= '0';
				end if;
            if REG = "00000010" then
				   led_eight(1) <= '1';
				else
				   led_eight(1) <= '0';
				end if;
            if REG = "00000001" then
				   led_eight(0) <= '1';
            else
				   led_eight(0) <= '0';
				end if;					
         end if;				
		end process;

   
   left_right : process(CLK,rst,point_lose_left,point_lose_right) --�q�O��ܤ�V
	   begin
	      if rst = '1' then
			   REG <= "10000000";
		   elsif clk'event and clk = '1' then
		      case state_1 is
		         when right => --���k�]
					   if counter = 1000 then
						   if point_lose_right = '1' or point_lose_right_1 = '1' then --�k���s
							   REG <= "00000001";
							else
					         REG(6 downto 0)<=REG(7 downto 1);
		                  REG(7)<= '0';
							end if;
						end if;
		         when left =>  --�����]
					   if counter = 1000 then
						   if point_lose_left = '1' or point_lose_left_1 = '1' then --�����s
							   REG <= "10000000";
							else
					         REG(7 downto 1)<=REG(6 downto 0); 
		                  REG(0)<= '0';
							end if;
						end if;
					when others =>
					   null;
		      end case;
		   end if;
	   end process;
	
	
	cnt : process (clk) -- ����1uHZ
      begin
		   if rst = '1' then
			   counter <= 0;
				cnt_1HZ <= '0';
		   elsif CLK'EVENT AND CLK='1' then
			   counter <= counter + 1;
				if counter = 1000 then
				   counter <= 0;
				end if;
				if counter >= 500 then
				   cnt_1HZ <= '1';
				else
				   cnt_1HZ <= '0';
				end if;
			end if;
      end process;
			
      
	
	
		
end Behavioral;

