
def shared temp-table ttplanos  no-undo serialize-name "parametros"
    like segprestpar.

empty temp-table ttplanos.

for each segprestpar no-lock.
    create ttplanos.
    buffer-copy segprestpar to ttplanos.
end.
