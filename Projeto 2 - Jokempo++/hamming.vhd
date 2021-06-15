--! APAGAR ESSE TRECHO ANTES DE ENVIAR
entity flipflopd is
    port( 
      D, reset, clock, EN: in  bit;
      Q:                   out bit
    );
  end flipflopd;
  
  architecture behavior of flipflopd is
  begin
    process (reset, clock)
    begin
      if reset='0' then
        Q <= '0';
      elsif clock'EVENT and clock='1' and EN='1' then
        Q <= D;
      end if;
    end process ;
  end behavior; 
--!--------------------------------------------------------


entity hamming is
    port(
        entrada: in bit_vector(9 downto 0); --! 3 gestos mais 4 bits de paridade 
        dados: out bit_vector(5 downto 0);  --! 3 gestos, corrigindo erros de 1 bit
        erro: out bit                       --! erro não corrigido
    );
end hamming;

entity jkp3 is
    port (
      reset, clock:   in bit;                     
      loadA, loadB:   in bit;                       --! armazenam os gestos 
      atualiza:       in bit;                       --! atualiza o resultado z
      a1, a2, a3:     in bit_vector(1 downto 0);    --! gestos do jogador A para os 3 jogos
      b1, b2, b3:     in bit_vector(1 downto 0);    --! gestos do jogador B para os 3 jogos
      z:              out bit_vector(1 downto 0)   --! resultado da disputa
  
    ) ;
  end jkp3;  

  entity jkp3auto is
    port (
        reset, clock: in  bit;
        loadA, loadB: in  bit;                    --! armazenam os gestos
        atualiza:     in  bit;                    --! atualiza resultado z
        a1, a2, a3:   in  bit_vector(1 downto 0); --! gestos do jogador A para os 3 jogos
        b1, b2, b3:   in  bit_vector(1 downto 0); --! gestos do jogador B para os 3 jogos
        z:            out bit_vector(1 downto 0) --! resultado da disputa 
    );
    end entity jkp3auto;

    entity jokempo is
        port (
          a: in bit_vector(1 downto 0); --! gesto do jogador A
          b: in bit_vector(1 downto 0); --! gesto do jogador B
          y: out bit_vector(1 downto 0) --! resultado do jogo
        );
      end jokempo;

       -- T1A2:
  entity melhordetres is
    port(
        resultado1: in bit_vector(1 downto 0); --! resultado do jogo 1
        resultado2: in bit_vector(1 downto 0); --! resultado do jogo 2
        resultado3: in bit_vector(1 downto 0); --! resultado do jogo 3
        z:          out bit_vector(1 downto 0) --! resultado da disputa
    );
    end melhordetres;

      -- T1A3:
  entity jokempotriplo is
    port (
      a1, a2, a3: in bit_vector(1 downto 0); --! gesto do jogador A para 3 jogos
      b1, b2, b3: in bit_vector(1 downto 0); --! gesto do jogador B para os 3 jogos
      z:          out bit_vector(1 downto 0) --! resultado da disputa
    ) ;
  end jokempotriplo; 

architecture hamming_arch of hamming is
    signal p1, p2, p4, p8: bit_vector(5 downto 0);
    signal erro_p1, erro_p2, erro_p4, erro_p8: bit;
    signal casa_do_erro: bit_vector(4 to 0);
begin
   -- Bits de paridade: entrada(9), entrada(8), entrada(7), entrada(6)
    -- P1 = XOR (0, 2, 3, 4)              
    -- P2 = XOR (0, 2, 3, 5)                                                                                                      
    -- P4 = XOR (1, 2, 3)                                                                                                                
    -- P8 = XOR (4, 5) 
    
    -- Tentando resolver:
    -- P1 (1, 1, 0, 1, 1, 0) já tá na ordem certa, de entrada(5) a entrada(0)
    -- P2 (0, 1, 1, 0, 1, 0)
    -- P3 (0, 1, 1, 1, 0, 0)
    -- P4 (1, 0, 0, 0, 0, 0)


    --! corrigir
    erro_p1 <= entrada(6) XOR entrada(0);
    erro_p2 <= entrada(7) XOR entrada(0);
    erro_p1 <= entrada(8) XOR entrada(0); 
    erro_p1 <= entrada(9) XOR entrada(4);

    casa_do_erro <= erro_p1 & erro_p2 & erro_p4 & erro_p8; --! concatenacao
    
    dados(0) <= NOT entrada(0) when ( casa_do_erro = "1100" ) else entrada(0);
    dados(1) <= NOT entrada(1) when ( casa_do_erro = "0010" ) else entrada(1);
    dados(2) <= NOT entrada(2) when ( casa_do_erro = "1110" ) else entrada(2);
    dados(3) <= NOT entrada(3) when ( casa_do_erro = "0000")  else entrada(3);
    dados(4) <= NOT entrada(4) when ( casa_do_erro = "1001" ) else entrada(4);
    dados(5) <= NOT entrada(5) when ( casa_do_erro = "0101" ) else entrada(5);

end architecture hamming_arch;

architecture jkp3_arch of jkp3 is
    component flipflopd 
    port(
        D, reset, clock, EN: in  bit;
        Q:                   out bit 
    );
    end component;

    component jokempotriplo is
        port (
          a1, a2, a3: in bit_vector(1 downto 0); --! gesto do jogador A para 3 jogos
          b1, b2, b3: in bit_vector(1 downto 0); --! gesto do jogador B para os 3 jogos
          z:          out bit_vector(1 downto 0) --! resultado da disputa
        ) ;
    end component; 

    signal ff_a1_0, ff_a1_1, ff_a2_0, 
           ff_a2_1, ff_a3_0, ff_a3_1, 
           ff_b1_0, ff_b1_1, ff_b2_0,
           ff_b2_1, ff_b3_0, ff_b3_1: bit;
    
    signal ff_a1, ff_a2, ff_a3, ff_b1,
           ff_b2, ff_b3: bit_vector(1 downto 0);

    signal resultado_triplo: bit_vector(1 downto 0);

begin
----------! Flipflops dos gestos ----------------------
    a1_0: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadA,
        D => a1(0),
        Q => ff_a1_0
      );

    a1_1: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadA,
        D => a1(1),
        Q => ff_a1_1
      );
    
    a2_0: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadA,
        D => a2(0),
        Q => ff_a2_0
      );

    a2_1: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadA,
        D => a2(1),
        Q => ff_a2_1
      );
    
    a3_0: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadA,
        D => a3(0),
        Q => ff_a3_0
      );
    
    a3_1: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadA,
        D => a3(1),
        Q => ff_a3_1
      );
    
    b1_0: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadB,
        D => b1(0),
        Q => ff_b1_0
      );

    b1_1: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadB,
        D => b1(1),
        Q => ff_b1_1
      );
    
    b2_0: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadB,
        D => b2(0),
        Q => ff_b2_0
      );

    b2_1: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadB,
        D => b2(1),
        Q => ff_b2_1
      );
    
    b3_0: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadB,
        D => b3(0),
        Q => ff_b3_0
      );
    
    b3_1: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => loadB,
        D => b3(1),
        Q => ff_b3_1
      );
    ------------------------------------------------

    ff_a1 <= (ff_a1_1 & ff_a1_0);
    ff_a2 <= (ff_a2_1 & ff_a2_0);
    ff_a3 <= (ff_a3_1 & ff_a3_0);
    ff_b1 <= (ff_b1_1 & ff_b2_0);
    ff_b2 <= (ff_b2_1 & ff_b2_0);
    ff_b3 <= (ff_a1_1 & ff_b3_0);

    jogo_triplo: jokempotriplo port map(
        a1 => ff_a1,
        a2 => ff_a2,
        a3 => ff_a3,
        b1 => ff_b1,
        b2 => ff_b2,
        b3 => ff_b3,
        z  => resultado_triplo
    );
    
    ff_resultado_0: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => atualiza,
        D => resultado_triplo(0),
        Q => z(0)  
      );
    
    ff_resultado_1: flipflopd port map(
        clock => clock,
        reset => reset,
        EN => atualiza,
        D => resultado_triplo(1),
        Q => z(1)  
      );
    
end architecture jkp3_arch;




--!---------------------------------------------------------------!--
--! Abaixo, apenas a cópia do Projeto 1, para instanciar o        !--
--!             component do jokempotriplo                        !--
--!---------------------------------------------------------------!--




-- ______________________Regras gerais:______________________ 
-- Pedra (01), Papel (10), Tesoura (11)
-- Cada jogador controla 6 bits (3 jogos)
-- Saida: 10 vit. A, 01 vit. B, 11 empate, 00 estado de espera 

-- T1A1:

  
  architecture jokempo_arch of jokempo is
  begin
      -- Para a resolução desta arquitetura, optei por reduzir as saídas
      -- em expressões boolenas. Para isto, considera-se as seguintes
      -- equivalências:
      
      -- A = a(0); B = a(1); C = b(0); D = b(1).
  
      -- y(1) = AB'C + ABD + BC'D + A'BCD'
      y(1) <= ((a(0) and not a(1)) and b(0)) or
              ((a(0) and a(1)) and b(1))    or
              ((a(1) and not b(0)) and b(1)) or
              ((not a(0) and a(1)) and (b(0) and not b(1))); -- Possivelmente estão invertidos as entradas (0 e 1)
      
      -- y(0) = ACD' + BCD + A'BD + AB'C'D
      y(0) <= ((a(0) and b(0)) and not b(1)) or
              ((a(1) and b(0)) and b(1))     or
              ((not a(0) and a(1)) and b(1)) or
              ((a(0) and not a(1)) and (not b(0) and b(1))); 
  
  end jokempo_arch;
  
 
    
  
  architecture melhordetres_arch of melhordetres  is
  begin
  
      z <= "00" when (
                      (resultado1 = "00" or resultado2 = "00" or resultado3 = "00")
                      ) else
           "01" when (
                      ((resultado1 = "01" and resultado2 = "01") 
                      or (resultado2 = "01" and resultado3 = "01")) 
                      or (resultado1 = "01" and resultado3 = "01")
                      or (resultado1 = "01" and resultado2 = "11" and resultado3 = "11")
                      or (resultado1 = "11" and resultado2 = "01" and resultado3 = "11")
                      or (resultado1 = "11" and resultado2 = "11" and resultado3 = "01")
                      ) else
           "10" when (
                      ((resultado1 = "10" and resultado2 = "10") 
                      or (resultado2 = "10" and resultado3 = "10")) 
                      or (resultado1 = "10" and resultado3 = "10")
                      or (resultado1 = "10" and resultado2 = "11" and resultado3 = "11")
                      or (resultado1 = "11" and resultado2 = "10" and resultado3 = "11")
                      or (resultado1 = "11" and resultado2 = "11" and resultado3 = "10")
                      ) else
           "11";
    
  end melhordetres_arch; 
  

  
  architecture jokempotriplo_arch of jokempotriplo is
    component jokempo 
      port(
        a: in bit_vector(1 downto 0); 
        b: in bit_vector(1 downto 0); 
        y: out bit_vector(1 downto 0) 
      );
      end component;
  
    component melhordetres     
      port(
        resultado1: in bit_vector(1 downto 0);
        resultado2: in bit_vector(1 downto 0);
        resultado3: in bit_vector(1 downto 0);
        z:  out bit_vector(1 downto 0)
      );
    end component;  
  
    signal vencedor1, vencedor2, vencedor3: bit_vector(1 downto 0);
  
  begin
    jogo1: jokempo port map(
      a => a1,
      b => b1,
      y => vencedor1
    );
  
    jogo2: jokempo port map(
      a => a2,
      b => b2,
      y => vencedor2
    );
  
    jogo3: jokempo port map(
      a => a3,
      b => b3,
      y => vencedor3
    );
  
    md3: melhordetres port map(
      resultado1 => vencedor1,
      resultado2 => vencedor2,
      resultado3 => vencedor3, 
      z => z
    );
  
  end jokempotriplo_arch;