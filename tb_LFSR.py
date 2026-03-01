def generate_golden():
    # G(x) = x^58 + x^39 + 1
    lfsr = 0x3FFFFFFFFFFFFFF # 58-bit all ones
    
    # 測試兩筆全 0 的 64-bit 資料
    test_inputs = [0x0000000000000000, 0x0000000000000000]
    
    for idx, data_64 in enumerate(test_inputs):
        scrambled_64 = 0
        for i in range(64):
            data_bit = (data_64 >> i) & 1
            # Taps at 58 (idx 57) and 39 (idx 38)
            b58 = (lfsr >> 57) & 1
            b38 = (lfsr >> 38) & 1
            
            s_bit = data_bit ^ b58 ^ b38
            scrambled_64 |= (s_bit << i)
            
            # Update LFSR (Self-synchronizing: shift in the scrambled bit)
            lfsr = ((lfsr << 1) | s_bit) & 0x3FFFFFFFFFFFFFF
            
        print(f"Cycle {idx} Payload: {scrambled_64:016x}")

if __name__ == "__main__":
    generate_golden()