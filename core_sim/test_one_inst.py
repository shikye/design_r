#python test_one_inst.py(argv[0]) ../verilog_mem/xx(argv[1])
import os,sys

def test_one_inst():


    cmd_rm = 'rm *.dump'
    os.popen(cmd_rm)

    tb_inst = sys.argv[1].split('/')[-1].split('.')[0]
    cmd_cp_dump = 'cp'+' '+ '../verilog_mem/' + tb_inst + '.dump' + ' ' + tb_inst + '.dump'
    os.popen(cmd_cp_dump)



    cmd_cp = 'cp'+' '+sys.argv[1]+' '+'inst'
    os.popen(cmd_cp)
    cmd_compile = 'make compile_tb'
    os.system(cmd_compile)
    cmd_run = 'make run'
    f = os.popen(cmd_run)
    r = f.read()
    f.close()

    tb_inst = sys.argv[1].split('/')[-1].split('.')[0]


    if (r.find('PASS') != -1):
        print(tb_inst+' '+'PASS')
        return 0
    else:
        print(tb_inst+' '+'FAIL')
        return 1
    

if __name__ == '__main__':
    sys.exit(test_one_inst())