# asks user which file, etc
import os
import teradata
import subprocess
from getpass import getpass

def reDelim(in_str, new_d, old_d):
    in_str = in_str.strip('\n')
    in_str = in_str.replace('"""', '"')
    in_str = in_str.replace('""', "'")
    out_str = ''
    quoted = False
    prev_char = None
    for s in in_str:
        if quoted:
            if s == '"':
                # print('')
                quoted = False
            else:
                # print(s, end='')
                out_str += s
        else:
            if s == old_d:
                out_str += new_d
            elif s == '"':
                quoted = True
                # print('Quoted: ')
            else:
                out_str += s
        prev_char = s
    return out_str

print('''============================================================''')
print('''    CSV TO TDP5 FILE LOADER (POWERED BY TDLOAD + PYTHON)    ''')
print('''============================================================''')
print()
print('''                DRAG THE SOURCE FILE HERE                   ''')
print()
print('''============================================================''')

old_path = input('SOURCE FILE PATH: ')
new_path = old_path[:-4]+'_STG.csv'
old_delim = input('ENTER DELIMITER USED IN SOURCE FILE: ')
new_delim = input('ENTER DELIMITER TO USE IN STAGING FILE: ')
remove_header = input('DOES THE SOURCE FILE CONTAIN A HEADER ROW?: (y/n) ')
skip_first = True if remove_header.lower() == 'y' else False
if skip_first:
    print('REMOVING HEADER...')

col_len = {}
num_col = -1
line_counter = 1
first = True
with open(old_path, 'r') as old:
    with open(new_path, 'w') as new:
        for l in old:
            l_new = reDelim(l, new_delim, old_delim)
            if first:
                first = False
                num_col = l_new.count(new_delim)
                for col in l_new.split(new_delim):
                    col_len[col] = 0
                if skip_first:
                    line_counter += 1
                    continue
            if new_delim != old_delim and new_delim in l:
                print("ERROR: FOUND '{}' WITHIN DATA! NOT A VALID DELIMITER. CHOOSE ANOTHER.".format(new_delim))
                quit()
            if num_col < l_new.count(new_delim):
                print("ERROR: TOO MANY COLUMNS IN LINE {}".format(line_counter))
                if new_delim == old_delim:
                    print('TRY AGAIN WITH ALTERNATIVE DELIMITER.')
                quit()
            if num_col > l_new.count(new_delim):
                print("ERROR: TOO FEW COLUMNS IN LINE {}".format(line_counter))
                if new_delim == old_delim:
                    print('TRY AGAIN WITH ALTERNATIVE DELIMITER.')
                quit()
            split_line = l_new.split(new_delim)
            for col, val in zip(col_len, split_line):
                if col_len[col] < len(val):
                    col_len[col] = len(val)
            new.write(l_new+'\n')
            line_counter += 1
print('STAGING FILE CREATED: {}'.format(new_path))

database = input('ENTER DATABASE FOR IMPORT: ')
table_name = input('ENTER TABLE NAME FOR IMPORT: ')

username = input('ENTER USERNAME FOR TDP5: ')
password = getpass('ENTER PASSWORD FOR TDP5: ')
if skip_first:
    create_schema = input('WOULD YOU LIKE TO CREATE A SCHEMA BASED ON THE DATA?: (y/n) ')
    if create_schema.lower() == 'y':
        create_query = '''
        CREATE MULTISET TABLE {}.{},
            FALLBACK,
            NO BEFORE JOURNAL,
            NO AFTER JOURNAL,
            CHECKSUM = DEFAULT,
            DEFAULT MERGEBLOCKRATIO,
            MAP = TD_MAP2
            (
        '''.format(database, table_name)
        print('''============================================================''')
        print('{:40s} : {}'.format('COLUMN', 'LENGTH'))
        print('''============================================================''')
        for col in col_len:
            print('{:40s} : {}'.format(col, col_len[col]))
            create_query += '        "{}" VARCHAR({}),\n'.format(col, col_len[col])
        # remove last comma
        create_query = create_query[:-2]
        index = input('Please enter comma delimited primary index(s) : ')
        create_query += '''\n    )\nPRIMARY INDEX ( {} );'''.format(index)
        print('''============================================================''')

        udaExec = teradata.UdaExec(appName="csv_loader", version="1.0", logConsole=False)
        session = udaExec.connect(method='odbc', driver='Teradata Database ODBC Driver 17.00', system='tdp5dbcw.teradata.westpac.com.au', username=username, password=password)

        print('''
        ============================================================
            DROP TABLE {}.{} (IF EXISTS) ?
        ============================================================
        '''.format(database, table_name))
        drop_flag = input('(y/n): ')
        if drop_flag.lower() == 'y':
            try:
                session.execute("DROP TABLE {}.{};".format(database, table_name))
            except(Exception) as ep:
                print('ERROR DROPPING TABLE {}.{}'.format(database, table_name))
                pass

        print('''
        ============================================================
                 CREATING TABLE USING THE FOLLOWING SCHEMA
        ============================================================
        ''')
        print(create_query)
        try:
            session.execute(create_query)
            print('''
            ============================================================
                           QUERY EXECUTING... PLEASE WAIT
            ============================================================
            ''')
        except(Exception) as ep:
            print('ERROR CREATING TABLE {}.{}'.format(database, table_name))
            pass

print('''
============================================================
                  LOADING DATA INTO TABLE
============================================================
''')

# run tdload
job = 'tdload --SourceFileName "{}" --SourceTextDelimiter "{}" --TargetTdpId "tdp5dbcw.teradata.westpac.com.au" --TargetUserName "{}" --TargetUserPassword "{}" --TargetWorkingDatabase "{}" --TargetTable "{}"'.format(new_path, new_delim, username, password, database, table_name)
# print(job)
# start = input('Start job?')
# if start != 'y':
#     quit()
subprocess.call(job, shell=True)
