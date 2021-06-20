entity hamming is
    port(
        entrada: in bit_vector(9 downto 0); --! 3 gestos mais 4 bits de paridade 
        dados: out bit_vector(5 downto 0);  --! 3 gestos, corrigindo erros de 1 bit
        erro: out bit                       --! erro não corrigido
    );
end hamming;

architecture hamming_arch of hamming is
    signal paridade_p1, paridade_p2, paridade_p4, paridade_p8: bit;
    signal tentativaDeCorrecao: bit_vector(5 downto 0);
    signal erroDaTentativa: bit;
begin
   -- Bits de paridade: entrada(3), entrada(2), entrada(1), entrada(0)
   -- Bits de dado: ent(9), ent(8), ent(7), ent(6), ent(5), ent(4)
   --                 10      9       7       6       5       3    | Casas no modo normal     
    
    -- p1 = 8 XOR 7 XOR 5 XOR 4
    -- p2 = 9 XOR 7 XOR 6 XOR 4
    -- p4 = 7 XOR 6 XOR 5 
    -- p8 = 9 XOR 8
    
    paridade_p1 <=                entrada(8) XOR entrada(7)                XOR entrada(5) XOR entrada(4) XOR entrada(0);
    paridade_p2 <= entrada(9)                XOR entrada(7) XOR entrada(6)                XOR entrada(4) XOR entrada(1);
    paridade_p4 <=                               entrada(7) XOR entrada(6) XOR entrada(5)                XOR entrada(2); 
    paridade_p8 <= entrada(9) XOR entrada(8)                                                             XOR entrada(3);

    tentativaDeCorrecao(5) <= NOT entrada(9) when ( ((paridade_p8 and paridade_p2) = '1') and (paridade_p1 = '0') and (paridade_p4 = '0')) else entrada(9);
    tentativaDeCorrecao(4) <= NOT entrada(8) when ( ((paridade_p8 and paridade_p1) = '1') and (paridade_p2 = '0') and (paridade_p4 = '0') ) else entrada(8);
    tentativaDeCorrecao(3) <= NOT entrada(7) when ( ((paridade_p4 and paridade_p2 and paridade_p1) = '1') and (paridade_p8 = '0') ) else entrada(7);
    tentativaDeCorrecao(2) <= NOT entrada(6) when ( ((paridade_p4 and paridade_p2) = '1') and (paridade_p1 = '0') and (paridade_p8 = '0'))  else entrada(6);
    tentativaDeCorrecao(1) <= NOT entrada(5) when ( ((paridade_p4 and paridade_p1) = '1' ) and (paridade_p2 = '0') and (paridade_p8 = '0')) else entrada(5);
    tentativaDeCorrecao(0) <= NOT entrada(4) when ( ((paridade_p2 and paridade_p1) = '1' ) and (paridade_p4 = '0') and (paridade_p8 = '0')) else entrada(4);

    -- Verificamos se depois da tentativa de correcao, os bits de paridade estao
    -- corretos. Caso nao estejam, ainda ha um erro detectavel (mas nao corrigivel).
    -- Nesse caso, erro eh igual a 1 e a saida dados fica igual a entrada.

    erroDaTentativa <= '1' when (tentativaDeCorrecao(4) XOR tentativaDeCorrecao(3) XOR tentativaDeCorrecao(1) XOR tentativaDeCorrecao(0) XOR entrada(0)) = '1' else
                       '1' when (tentativaDeCorrecao(5) XOR tentativaDeCorrecao(3) XOR tentativaDeCorrecao(2) XOR tentativaDeCorrecao(0) XOR entrada(1)) = '1' else
                       '1' when (tentativaDeCorrecao(3) XOR tentativaDeCorrecao(2) XOR tentativaDeCorrecao(1)                            XOR entrada(2)) = '1' else 
                       '1' when (tentativaDeCorrecao(5) XOR tentativaDeCorrecao(4)                                                       XOR entrada(3)) = '1' else
                       '0';

    dados <= tentativaDeCorrecao when erroDaTentativa = '0' else entrada(9 downto 4);
    -- erro <= erroDaTentativa 
    erro <= (paridade_p8 and paridade_p4) or (paridade_p8 and paridade_p2 and paridade_p1);

end architecture hamming_arch;