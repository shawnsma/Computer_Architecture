import java.util.*;
import java.io.File;
import java.io.FileNotFoundException;

class CacheBlock {
    boolean valid;
    boolean dirty;
    int tag;
    int block_start;
    int address;
    int lur;
}

public class cachesim {

    public static int log2(int n) {
        int r = 0;
        while (n > 1) {
            n = n >> 1;
            r++;
        }
        return r;
    }

    public static int power2(int n) {
        int r = 1;
        while (n > 1) {
            r = 2 * r;
            n--;
        }
        return r;
    }

    public static int ones(int n) {
        return (1 << n) - 1;
    }

    public static String hexConvert(String address) {

        HashMap<Character, String> hashMap = new HashMap<Character, String>();
        hashMap.put('0', "0000");
        hashMap.put('1', "0001");
        hashMap.put('2', "0010");
        hashMap.put('3', "0011");
        hashMap.put('4', "0100");
        hashMap.put('5', "0101");
        hashMap.put('6', "0110");
        hashMap.put('7', "0111");
        hashMap.put('8', "1000");
        hashMap.put('9', "1001");
        hashMap.put('a', "1010");
        hashMap.put('b', "1011");
        hashMap.put('c', "1100");
        hashMap.put('d', "1101");
        hashMap.put('e', "1110");
        hashMap.put('f', "1111");

        if (address.length() < 3) {
            throw new IllegalArgumentException("Invalid address: " + address);
        }

        StringBuilder initial = new StringBuilder();
        address = address.substring(2).toLowerCase();

        for (char ch : address.toCharArray()) {
            String binary = hashMap.get(ch);
            if (binary == null) {
                throw new IllegalArgumentException("Invalid hex character: " + ch);
            }
            initial.append(binary);
        }

        while (initial.length() < 24) {
            initial.insert(0, "0");
        }

        return initial.toString();
    }

    public static int deciconvert(String bin) {
        if (bin.isEmpty())
            return 0;
        return Integer.parseInt(bin, 2);
    }

    public static String[] memoryMod(int offset) {
        int size = 1 << (24 - offset);
        String[] mainMem = new String[size];
        Arrays.fill(mainMem, "0".repeat(2 * offset));
        return mainMem;
    }

    public static CacheBlock[][] cacheMod(int asso, int block, int csize) {
        int numRow = 1 << block;
        CacheBlock[][] cache = new CacheBlock[numRow][asso];
        for (int i = 0; i < numRow; i++) {
            for (int j = 0; j < asso; j++) {
                cache[i][j] = new CacheBlock();
                cache[i][j].tag = 0; // Initialize tag
                cache[i][j].valid = false;
                cache[i][j].dirty = false;
                cache[i][j].lur = 0;
            }
        }
        return cache;
    }

    public static void main(String args[]) throws FileNotFoundException {
        if (args.length < 4) {
            System.out.println("Usage: java cachesim <traceFile> <size> <asso> <block>");
            return;
        }
        String traceFile = args[0];
        int csize = Integer.parseInt(args[1]);
        int asso = Integer.parseInt(args[2]); // log2 asso is index
        int block = Integer.parseInt(args[3]); // log2 block is offset
        int index = log2(asso);
        int offset = log2(block);
        int indexpl = log2(csize) - offset - index + 10;
        int clock = 0;
        // everything else is the tag

        String[] mainMem = new String[1 << 24];
        CacheBlock[][] cache = cacheMod(asso, indexpl, csize); // tag, info, valid, LRU

        Scanner sc = new Scanner(new File(traceFile));
        while (sc.hasNext()) {
            clock++;
            String inst = sc.next();
            int unproc = Integer.parseInt(sc.next().substring(2), 16);
            int accessSize = Integer.parseInt(sc.next());
            int setno = (unproc >> offset) & ones(indexpl);
            int tag = unproc >> (offset + indexpl);

            boolean hm = false;
            int hitIndex = 0;
            for (int i = 0; i < asso; i++) {
                if (cache[setno][i].tag == tag && cache[setno][i].valid) {
                    hm = true;
                    hitIndex = i;
                }
            }

            if (inst.equals("load")) {

                String to_print = "";
                String mem_data = "";
                for (int i = 0; i < accessSize; i++) {
                    mem_data = mainMem[i + unproc];
                    if (mem_data == null) {
                        mem_data = "00";
                    }
                    to_print = to_print + (mem_data);
                }
                if ((to_print.length() - (accessSize * 2)) == -1) {
                    to_print = "0" + to_print;
                }

                if (hm) {
                    System.out.print(inst + " ");
                    System.out.print("0x" + Integer.toHexString(unproc) + " ");
                    System.out.print("hit ");
                    System.out.print(to_print + "\n");
                    cache[setno][hitIndex].valid = true;
                    cache[setno][hitIndex].lur = clock;
                } else {
                    int invalid_add = -1;
                    for (int i = 0; i < asso; i++) {
                        if (cache[setno][i].valid == false) {
                            invalid_add = i;
                        }
                    }
                    if (invalid_add != -1) {
                        System.out.print(inst + " ");
                        System.out.print("0x" + Integer.toHexString(unproc) + " ");
                        System.out.print("miss ");
                        System.out.print(to_print + "\n");
                        cache[setno][invalid_add].valid = true;
                        cache[setno][invalid_add].dirty = false;
                        cache[setno][invalid_add].lur = clock;
                        cache[setno][invalid_add].tag = tag;
                    } else {
                        int min_lur = Integer.MAX_VALUE;
                        int min_lur_ind = -1;
                        for (int i = 0; i < asso; i++) {
                            if (cache[setno][i].lur < min_lur) {
                                min_lur = cache[setno][i].lur;
                                min_lur_ind = i;
                            }
                        }
                        System.out.print("replacement 0x");
                        String bloackAddy = Integer
                                .toHexString(((cache[setno][min_lur_ind].tag << indexpl) + setno) << offset);
                        System.out.print(bloackAddy);
                        if (cache[setno][min_lur_ind].dirty) {
                            System.out.print(" dirty\n");
                        } else {
                            System.out.print(" clean\n");
                        }
                        System.out.print(inst + " ");
                        System.out.print("0x" + Integer.toHexString(unproc) + " ");
                        System.out.print("miss ");
                        System.out.print(to_print + "\n");
                        cache[setno][min_lur_ind].dirty = false;
                        cache[setno][min_lur_ind].valid = true;
                        cache[setno][min_lur_ind].lur = clock;
                        cache[setno][min_lur_ind].tag = tag;
                    }
                }
            } else {

                String info = sc.next();
                if (accessSize == 1) {
                    mainMem[unproc] = info;
                } else {
                    int access_num = 0;
                    for (int i = 0; i < accessSize; i++) {
                        mainMem[unproc + i] = info.substring(access_num, access_num + 2);
                        access_num += 2;
                    }
                }
                if (hm) {
                    System.out.print(inst + " ");
                    System.out.print("0x" + Integer.toHexString(unproc) + " ");
                    System.out.print("hit\n");
                    cache[setno][hitIndex].dirty = true;
                    cache[setno][hitIndex].valid = true;
                    cache[setno][hitIndex].lur = clock;
                } else {
                    int invalid_add = -1;
                    for (int i = 0; i < asso; i++) {
                        if (cache[setno][i].valid == false) {
                            invalid_add = i;
                        }
                    }
                    if (invalid_add != -1) {
                        System.out.print(inst + " ");
                        System.out.print("0x" + Integer.toHexString(unproc) + " ");
                        System.out.print("miss\n");
                        cache[setno][invalid_add].dirty = true;
                        cache[setno][invalid_add].valid = true;
                        cache[setno][invalid_add].lur = clock;
                        cache[setno][invalid_add].tag = tag;
                    } else {
                        int min_lur = Integer.MAX_VALUE;
                        int min_lur_ind = -1;
                        for (int i = 0; i < asso; i++) {
                            if (cache[setno][i].lur < min_lur) {
                                min_lur = cache[setno][i].lur;
                                min_lur_ind = i;
                            }
                        }
                        System.out.print("replacement 0x");
                        String bloackAddy = Integer
                                .toHexString(((cache[setno][min_lur_ind].tag << indexpl) + setno) << offset);
                        System.out.print(bloackAddy);
                        if (cache[setno][min_lur_ind].dirty) {
                            System.out.print(" dirty\n");
                        } else {
                            System.out.print(" clean\n");
                        }
                        System.out.print(inst + " ");
                        System.out.print("0x" + Integer.toHexString(unproc) + " ");
                        System.out.print("miss\n");
                        cache[setno][min_lur_ind].dirty = true;
                        cache[setno][min_lur_ind].valid = true;
                        cache[setno][min_lur_ind].lur = clock;
                        cache[setno][min_lur_ind].tag = tag;
                    }
                }

            }
        }
        sc.close();
    }
}
