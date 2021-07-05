entity bass_hero_solo is
  port (clk, reset: in bit;                    
        target:     in bit_vector(3 downto 0);  --! Nota que o jogador precisa acertar
        played:     in bit_vector(3 downto 0);  --! Comando do jogador
        score:      out bit_vector(2 downto 0); --! Pontuacao atual do jogador 
        cheers:     out bit                     --! Streak de acertos > 2

  ) ;
end bass_hero_solo;

architecture bass_hero_solo_arch of bass_hero_solo is
    type state_type is (neg_dois, neg_um, zero, um, dois, dois_plus);
    signal state, next_state: state_type;
    signal target_equals_played: bit;


begin

    mem_proc: process(reset, clk) -- bloco de memoria
    begin
        if (played = target) then
            target_equals_played <= '1';
        else
            target_equals_played <= '0';
        end if;
            

        if clk'event and clk = '1' then --! borda de subida
            if reset = '1' then
                state <= zero; --! inicio (reset sincrono)
            else
                state <= next_state;
            end if;
        end if;
    end process;

    ----------- Maquina de estados para contabilizar os pontos, com limites em 2 pos. e 2 neg. -----------
    next_state <= neg_um when (state = zero and target_equals_played = '0') or (state = neg_dois and target_equals_played = '1') else
                  neg_dois when (state = neg_um and target_equals_played = '0') or (state = neg_dois and target_equals_played = '0') else
                  um when (state = zero and target_equals_played = '1') or (state = dois and target_equals_played = '0') or (state = dois_plus and target_equals_played = '0') else
                  dois when (state = um and target_equals_played = '1')  else
                  dois_plus when (state = dois and target_equals_played = '1') or (state = dois_plus and target_equals_played = '1') else
                  zero;
    -------------------------------------------------------------------------------------------------------

    score <= "000" when state = zero   else
             "001" when state = um     else
             "010" when state = dois or state = dois_plus else
             "111" when state = neg_um else
             "110" when state = neg_dois;  

    with state select 
        cheers <= '1' when dois_plus,
                  '0' when others;

end bass_hero_solo_arch; -- bass_hero_solo_arch