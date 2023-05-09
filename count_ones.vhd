    entity count_ones is 
        generic (
            g_VECTOR_LENGTH := 8
        );
        port (
            i_data          : std_logic_vector(g_VECTOR_LENGTH-1 downto 0);
            o_num_of_ones   : std_logic
        );
    end entity;
