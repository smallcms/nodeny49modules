#!/usr/bin/perl
# ------------------- NoDeny ------------------
# Copyright (с) Volik Stanislav, 2008, 2009
# Read license http://nodeny.com.ua/license.txt
# ---------------------------------------------
#
# ------- Detail Traffic using HighCharts -----
# Some parts of the functions are by Volik Stanislav
# Used highcharts lib from http://www.highcharts.com
# Development of the module: 
# Andrey Miroshnichenko <zentavr@trafford.com.ua>
#
use Time::gmtime;
$VER=49.32;

&TSHC_init;

$preset=$U{$Mid}{preset};
# список направлений, которые имеют названия. Если у направления нет названия, а трафик есть - проблемы в настройках
# и это обнаружится при посуточном просмотре статистики
$out=join '',map{ &ahref("$scrpt&when=$when&class=$_",$c[$_]).$br if $_==1 || $PresetName{$preset}{$_} } (1..8);

# Направления и календарик слева в меню
$OUTLEFT.=&div('cntr',&Mess3('row2','Направления:'.$br2.$out).&Get_list_of_stat_days($dbs,'x',"$scrpt&class=$class&when=",$when));

sub TSHC_init
{
 &Connect_DB2;
 $when=int $F{when} || $t;
 $class=int $F{class};
 $class=1 if $class<1 || $class>8;
}
 
sub TSHC_main
{
 &TSHC_init;
 # Необходимо аджаксом отдать значения
 #if(exists($F{ajax})){
 #	$answer = '';
 #	# И отправим клиенту всю эту бадягу
 #	print "Content-type: application/json\n\n".$answer;			
 #	exit;
 #}
 
 $scrpt.="&when=$when&class=$class";
 $tm=localtime($when);
 $day=$tm->mday;
 $mon=$tm->mon;
 $year=$tm->year;
 $year_full=$year+1900;
 $mon++;
 $tname=$year_full.'x'.$mon.'x'.$day;	# часть имени таблицы для трафика запрошенного дня
 
 $sql="SELECT SUM(`in`) AS input ,SUM(`out`) AS output,time FROM x$tname WHERE mid IN ($Sel_id) AND class=$class AND (`in`>0 OR `OUT`>0) GROUP BY time ORDER BY time ASC";
 $sth=&sql($dbs,$sql);
 $t_input = ''; $t_output = '';
 
 # Подсчитаем сдвиг часового пояса от ЖМТ на сервере. Потому что на стороне клиента считаться будет не правильно (точнее по UTC)
 $gmt_offset_in_seconds = timegm($tm->sec(), $tm->min(), $tm->hour(), $tm->mday(), $tm->mon(), $tm->year()) - timelocal($tm->sec(), $tm->min(), $tm->hour(), $tm->mday(), $tm->mon(), $tm->year());
 #$gmt_offset_in_seconds = 0;
 
 while($p=$sth->fetchrow_hashref){
	#$fulltime  = ($p->{'time'} + (3600*3)) * 1000;
	$fulltime  = ($p->{'time'} + $gmt_offset_in_seconds) * 1000;

	$t_input  .= "\n".'['.$fulltime.','.$p->{'input'}.'],';
	$t_output .= "\n".'['.$fulltime.','.$p->{'output'}.'],';	
 }
 #$OUT.=$sql;
 $t_input =~ s/,$//;
 $t_output =~ s/,$//;
 #$t_time   =~ s/,$//;
 
 # Отобразим график
 $OUT.='<script type="text/javascript" src="/js/jquery/1.7.1/jquery.min.js"></script>';
 $OUT.='<script src="/js/hc/highcharts.js"></script>';
 $OUT.='<div id="traffic_chart" style="min-width: 400px; height: 400px; margin: 0 auto"></div>';
 $h="на $day ".('','января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря')[$mon]." $year_full";
 $head = ($For_U? "Показана статистика для $For_U" : 'Показана суммарная статистика для всех ваших ip')." $c[$class] трафик $h";
 $OUT.='<script type="text/javascript">
$(function () {
    var chart;
    $(document).ready(function() {
        chart = new Highcharts.Chart({
            chart: {
                renderTo: \'traffic_chart\',
                type: \'area\'
            },
            title: {
                text: \''.&Filtr_all($head).'\'
            },
            xAxis: {
                title: {
					text: \'Время\'
				},
				type: \'datetime\',
				labels: {
                    formatter: function() {
                        return Highcharts.dateFormat(\'%e %b %Y, %H:%M\', this.value);
                    },
					rotation: -27,
					x: -45,
					y: 40
                }
            },
            yAxis: {
                title: {
                    text: \'Трафик, Кбайт\'
                },
				labels: {
                    formatter: function() {
                        return Highcharts.numberFormat(this.value/'.$kb.', 2) +\'k\';
                    }
                }
            },
            tooltip: {
                formatter: function() {
                    return this.series.name +\' скачано <b>\'+
                        Highcharts.numberFormat(this.y/'.$kb.', 2) +\'</b>Кбайт <br/>\'+ Highcharts.dateFormat(\'%e %b %Y, %H:%M\', this.x);
                }
            },
            plotOptions: {
                area: {
                    marker: {
                        enabled: false,
                        symbol: \'circle\',
                        radius: 2,
                        states: {
                            hover: {
                                enabled: true
                            }
                        }
                    }
                }
            },
            series: [{
                name: \'Входящий Трафик\',
                data: ['.$t_input.']
            }, {
                name: \'Исходящий Трафик\',
                data: ['.$t_output.']
            }]
        });
    });
    
});
		</script>';
 
 
 
}

1;      
