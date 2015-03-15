# Патч #
```

--- nomake.pl.old	2011-04-20 23:39:38.000000000 +0300
+++ nomake.pl	2011-04-20 23:51:06.000000000 +0300
@@ -57,7 +57,9 @@
 $Config_out=$1;
 $Config_out="$Program_dir/$Config_out" if $Config_out!~/^\//;
 $Reload_com=$config_in=~s/<reload>(.+)<\/reload>\n?//igs? $1 : '';
-$Template_num=$config_in=~s/<template>(\d+)<\/template>\n?//igs? $1 : 1;
+$Template_num=$config_in=~s/<template>(\d+||no)<\/template>\n?//igs? $1 : 1;
+$Sql_query=$config_in=~s/<query>(.+)<\/query>\n?//igs?$1:'';
+$Fields=$config_in=~s/<fields>(.+)<\/fields>\n?//igs?$1:'';
 
 # разобъем файл-шаблон на блоки, к которым применяются фильтры
 ($no_filtr_block,@blocks)=split /<filtr/,$config_in;
@@ -151,7 +153,7 @@
 sub Form_Config
 {
  $When_Form_Config=&TimeNow()+$t_reload_users;
- $sql="$SQL_BUF id,ip,name,state,auth,AES_DECRYPT(passwd,'$Passwd_Key') FROM $c{Db_usr_table} $Where_grp ORDER BY id";
+ $sql=$Sql_query || "$SQL_BUF id,ip,name,state,auth,AES_DECRYPT(passwd,'$Passwd_Key') FROM $c{Db_usr_table} $Where_grp ORDER BY id";
  $sth=&sql($sql);
  $sth or return;
 
@@ -165,25 +167,33 @@
  {
     $ok++;
     %f=( 'id'=>$p->{id}, 'ip'=>$p->{ip}, 'state'=>$p->{state}, 'auth'=>$p->{auth} );
+	{
+		$Fields or next;
+		foreach (split ',',$Fields){
+			&Debug("Fields: $Fields");
+			exists $p->{$_} or next;
+			$f{$_} = $p->{$_};
+		}
+	}
     $ip_raw=pack('CCCC', split /\./,$f{ip});
     $f{login}=$p->{name};
     &Debug("=== id: $f{id} === $f{ip} === $f{login} ===");
     $f{pass}=$p->{"AES_DECRYPT(passwd,'$Passwd_Key')"};
     $f{lat_login}=&translit($f{login});
-
-    $sql="SELECT field_alias,field_value FROM dopdata ".
-         "WHERE parent_type=0 AND template_num=$Template_num AND parent_id=$f{id} AND revision=".
-         "(SELECT MAX(revision) FROM dopdata WHERE parent_type=0 AND template_num=$Template_num AND parent_id=$f{id})";
-    &Debug($sql);
-    $sth2=$dbh->prepare($sql);
-    if( $sth2->execute )
-    {
-       while( $h=$sth2->fetchrow_hashref )
-       {
-          $f{'dopdata-'.$h->{field_alias}}=$h->{field_value};
-          &Debug('DOPDATA: '.$h->{field_alias}.' = '.$h->{field_value});
-       }
-    }
+	{
+		$Template_num eq 'no' && last;
+		$sql="SELECT field_alias,field_value FROM dopdata ".
+			 "WHERE parent_type=0 AND template_num=$Template_num AND parent_id=$f{id} AND revision=".
+			 "(SELECT MAX(revision) FROM dopdata WHERE parent_type=0 AND template_num=$Template_num AND parent_id=$f{id})";
+		&Debug($sql);
+		$sth2=$dbh->prepare($sql);
+		if( $sth2->execute ){
+			while( $h=$sth2->fetchrow_hashref ){
+				$f{'dopdata-'.$h->{field_alias}}=$h->{field_value};
+				&Debug('DOPDATA: '.$h->{field_alias}.' = '.$h->{field_value});
+			}
+		}
+	}
 
     foreach $i (0..$#b)
     {

```

**Суть патча:
  1. Основной запрос к базе можно задать из конфига:
```
<query>MAIN SQL QUERY</query>
```
  1. Поля, по которым можно вести сравнение тоже можно задать из конфига:
```
<fields>f1,f2,f3,f4,...,fn</fields>
```
  1. В таком параметре как `<template>` можно указать 'no', что скажет скрипту не делать выборку из доп данных (так мы можем выиграть в скорости)
Для чего? Будет на много проще**сформировать ПРАКТИЧЕСКИ любой конфиг**, не обязательно основываясь на таблице с юзерами.**

# Пример применения #

```

<file>/dev/null</file>
<template>no</template>
<query>select * from information_chema.tables</query>
<fields>TABLE_NAME</fields>

Tables which name begin with: "use"
<filtr TABLE_NAME='^use'><TABLE_NAME>
</filtr>

```