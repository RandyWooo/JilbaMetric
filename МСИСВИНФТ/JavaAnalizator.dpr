//metric: Jilba;
//programming language: Java;

Program JavaAnalizator;

{$APPTYPE CONSOLE}

Uses
  SysUtils,
  Windows;

Type
  Struct = Record
    conditions: integer;
    cycles: integer;
    total: integer;
    deep: integer;
    maxDeep: integer;
    endCycle :integer;
    endCondition : integer;
    ternarny: integer;
  end;

  pointerToStack = ^Stack;
  Stack = Record
    inCondition: Boolean;
    inCycle: Boolean;
    next: pointerToStack;
  end;

Function correctFile(const fileName: string): Boolean;
Var
  javaCodeFile: textFile;
Begin
  result := True;
  if fileExists(fileName) then
  begin
    assignFile(javaCodeFile, fileName);
    Reset(javaCodeFile);
    if (EOF(javaCodeFile)) then
    begin
      writeln('Файл пустой!');
      result := false;
    end;
    closeFile(javaCodeFile);
  end
  else
  begin
    writeln('Файл не найден!');
    result := False;
  end
End;

Procedure deleteQuotesFromOutput(var stringFromFile: string);
Var
  startComment, currentComment:integer;
Begin
  repeat
    currentComment := Pos('"', stringFromFile);
    startComment := currentComment;
    if (currentComment <> 0) then
    begin
      while((stringFromFile[currentComment+1] <> ('"')) and (currentComment <= length(stringFromFile) - 1)) do
        inc(currentComment);
      Delete(stringFromFile, startComment, currentComment - startComment + 2);
    end;
  until(currentComment = 0);
End;

Procedure createStack(Var Head: pointerToStack; Const Value: integer);
Var
  current: pointerToStack;
Begin
  new(current);
  if value = 0 then
  begin
    current.inCondition := True;
    current.inCycle := False;
  end;
  if value = 1 then
  begin
    current.inCondition := False;
    current.inCycle := True;
  end;
  current.next := nil;
  current.next := head;
  head := current;
End;

Procedure freeStack(Var Head: pointerToStack; Var Jilba: Struct);
Var
  current: pointerToStack;
Begin
  current := head;
  head := head.next;
  if (current.inCycle) then
  begin
    dec(Jilba.deep);
    dec(Jilba.endCycle);
  end
  else
    dec(Jilba.endCondition);
  dispose(current);
End;

//Операторы условия
Procedure ConditionOperators(const stringFromFile: string; var i: integer; var Jilba: struct; var head: pointerToStack);
Begin
  if (stringFromFile[i] = 'e') and (stringFromFile[i+1] = 'l') and (stringFromFile[i+2] = 's') and (stringFromFile[i+3] = 'e') then  // else
  begin
    inc(Jilba.conditions);
    inc(Jilba.total);
    i := i + 4;
  end
  else
  if (stringFromFile[i] = 'i') and (stringFromFile[i+1] = 'f') then  // if
  begin
    inc(Jilba.conditions);
    inc(Jilba.total);
    i := i + 2;
    createStack(head, 0);
    inc(Jilba.endCondition);
  end
  else
  if (stringFromFile[i] = 's') and (stringFromFile[i+1] = 'w') and (stringFromFile[i+2] = 'i') and (stringFromFile[i+3] = 't') and (stringFromFile[i+4] = 'c') and (stringFromFile[i+5] = 'h') then  // switch
  begin
    inc(Jilba.conditions);
    inc(Jilba.total);
    i:=i + 4;
    createStack(head, 0);
    inc(Jilba.endCondition);
  end
End;

Procedure Ternarny(const stringFromFile: string; var i: integer; var Jilba: struct);
var
  k: Integer;
begin
  if(stringFromFile[i] = '?') then
  begin
    k := i;
    while (k <= length(stringFromFile)) and (stringFromFile[k] <> ':') do
      Inc(k);
    if k <= length(stringFromFile) then
    begin
      inc(Jilba.ternarny);
      inc(Jilba.total);
      Inc(i);
    end
  end;
end;

//Циклы
Procedure cycleOperators(const stringFromFile: string; var i: integer; var Jilba: struct; var head: pointerToStack);
Begin
  if (stringFromFile[i] = 'w') and (stringFromFile[i+1] = 'h') and (stringFromFile[i+2] = 'i') and (stringFromFile[i+3] = 'l') and (stringFromFile[i+4] = 'e') then  // while
  begin
    inc(Jilba.deep);
    inc(Jilba.cycles);
    inc(Jilba.total);
    i := i + 5;
    createStack(head, 1);
    inc(Jilba.endCycle);
  end
  else
  if (stringFromFile[i] = 'f') and (stringFromFile[i+1] = 'o') and (stringFromFile[i+2] = 'r') then  // for
  begin
    inc(Jilba.deep);
    inc(Jilba.cycles);
    inc(Jilba.total);
    i := i + 3;
    createStack(head, 1);
    inc(Jilba.endCycle);
  end;
  if(Jilba.deep > Jilba.maxdeep) then
    Jilba.maxdeep := Jilba.deep;
End;

//Операторы сравнения:
Procedure comparisonOperators(const stringFromFile: string; var i: integer; var Jilba: struct);
Begin
  if (stringFromFile[i] = '=') and (stringFromFile[i+1] = '=') then
  begin
    inc(Jilba.total);
    i := i + 2;
  end
  else
  if (stringFromFile[i] = '>') and (stringFromFile[i+1] = '=') then
  begin
    inc(Jilba.total);
    i := i + 2;
  end
  else
  if (stringFromFile[i] = '!') and (stringFromFile[i+1] = '=') then
  begin
    inc(Jilba.total);
    i := i + 2;
  end
  else
  if (stringFromFile[i] = '<') and (stringFromFile[i+1] = '=') then
  begin
    inc(Jilba.total);
    i := i + 2;
  end
  else
  if (stringFromFile[i] = '>') and (stringFromFile[i+1] <> '=') then
  begin
    inc(Jilba.total);
    i := i + 1;
  end
  else
  if (stringFromFile[i] = '<') and (stringFromFile[i+1] <> '=') then
  begin
    inc(Jilba.total);
    i := i + 1;
  end
End;

//Другие операторы:
Procedure otherOperators(const stringFromFile: string; var i: integer; var Jilba: struct; var head: pointerToStack);
Begin
  if ((i = 1) or (stringFromFile[i-1] = ' ')) and ((Jilba.endCondition > 0) or (Jilba.endCycle > 0)) then
  begin
    i:=i+3;
    freeStack(head, Jilba);
  end
  else
  //Присваивание
  if (stringFromFile[i] = '=') and (stringFromFile[i+1] <> '=') then
  begin
    inc(Jilba.total);
    i := i + 1;
  end
  else
  if (stringFromFile[i] = '+') and (stringFromFile[i+1] = '=') then
  begin
    inc(Jilba.total);
    i := i + 2;
  end
  else
  if (stringFromFile[i] = '-') and (stringFromFile[i+1] = '=') then
  begin
    inc(Jilba.total);
    i := i + 2;
  end
  else
  if (stringFromFile[i] = '*') and (stringFromFile[i+1] = '=') then
  begin
    inc(Jilba.total);
    i := i + 2;
  end
  else
  if (stringFromFile[i] = '%') and (stringFromFile[i+1] = '=') then
  begin
    inc(Jilba.total);
    i := i + 2;
  end
End;

//Местонахождение (строка или комментарий)
Function stringOrComment(const stringFromFile: string; var i: integer; var pointerToComment: PBoolean; Var inString: boolean): Boolean;
Var
  comment: boolean;
Begin
  result := False;
  comment := False;
  if (pointerToComment^) then
    Comment := True;
  //Проверяем находимся ли мы в строке:
  if (not inString) and (Length(stringFromFile) = 0)then
    inString := True
  else
  if (inString) and (Length(stringFromFile) = 0) then
    inString := False;
  //Однострочные комментарии:
  if (stringFromFile[i] = '/') and (stringFromFile[i+1] = '/') and (not pointerToComment^) and (not Comment) then
  begin
    comment := True;
    i := length(stringFromFile);
  end;
  //Многострочные комментарии
  if (stringFromFile[i] = '/') and (not pointerToComment^) and (stringFromFile[i+1] = '*') then
  begin
    comment := True;
    pointerToComment^ := True;
    i := i + 2;
  end;
  if (stringFromFile[i] = '*') and (pointerToComment^) and (stringFromFile[i+1] = '/') then
  begin
    pointerToComment^ := False;
    comment := False;
    i := i + 2;
  end;
  if (comment) or (inString) then
    Result := True;
End;

Procedure checkString(Const stringFromFile: string; var Jilba: struct; Var PComment: PBoolean; Var Head: pointerToStack);
Var
  i: integer;
  inString: boolean;
Begin
  i := 1;
  inString := False;
  while i <= length(stringFromFile) do
  begin
    if not stringOrComment(stringFromFile, i, Pcomment, inString) then
    begin
      //Поиск операторов условия:
      conditionOperators(stringFromFile, i, Jilba, head);
      //Поиск операторов цикла:
      cycleOperators(stringFromFile, i, Jilba, head);
      //Поиск операторов сравнения:
      comparisonOperators(stringFromFile, i, Jilba);
      //Поиск остальных операторов:
      otherOperators(stringFromFile, i, Jilba, head);
      //Поиск тернарных операторов
      Ternarny(stringFromFile, i, Jilba);
    end;
    inc(i);
  end;
End;

Const
  fileName = 'javacode1.txt';

Var
  Jilba: Struct;
  javaCodeFile: Textfile;
  stringFromFile: string;
  pointerToComment: PBoolean;
  Head: pointerToStack;

Begin
  SetConsoleCP(1251);
  SetConsoleOutPutCp(1251);
  Jilba.conditions := 0;
  Jilba.cycles := 0;
  Jilba.maxdeep := 0;
  Jilba.deep := 0;
  Jilba.total := 0;
  Jilba.ternarny := 0;
  Jilba.endCycle := 0;
  Jilba.endCondition := 0;

  if correctFile(fileName) then
  begin
    writeln('Java code:');
    new(head);
    new(pointerToComment);
    pointerToComment^ := False;
    assignFile(javaCodeFile, FileName);
    Reset(javaCodeFile);
    while not EOF(javaCodeFile) do
    begin
      readln(javaCodeFile, stringFromFile);
      writeln(stringFromFile);
      deleteQuotesFromOutput(stringFromFile);
      checkString(stringFromFile, Jilba, pointerToComment, Head);
    end;
    closeFile(javaCodeFile);

    writeln;
    writeln('Общее число операторов: ', Jilba.total);
    writeln('Общее число условий: ', Jilba.conditions + Jilba.ternarny);
    //writeln('Число тернарных операторов: ', data.ternarny);
    writeln('Общее число циклов: ', Jilba.cycles);
    writeln('Максимальная вложенность циклов: ', Jilba.maxdeep);
    writeln('Кол-во циклов/Общее число операторов: ', Jilba.cycles/Jilba.total:0:5);
    writeln('Кол-во операторов условия/Общее число операторов: ', (Jilba.conditions+Jilba.ternarny)/Jilba.total:0:5);
  end
  else
    writeln('Oops, возникли проблемы с файлом!');
  readln;
End.



