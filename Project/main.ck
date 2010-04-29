//Build base melodic info

int melody[10][4];

// Scales
[ 57, 59, 60, 62, 64, 65, 67, 69 ] @=> int a_minor_dia[];

a_minor_dia @=> int basic_scale[];

// Initialize melodic line.
set_melody(melody);


// Main gain control.
Gain main_gain;
1 => main_gain.gain;


//Intro
spork ~ intro_gain(main_gain, 70);
intro(main_gain, 75);


//First movement
1 => main_gain.gain;
//Machine.add("intro.ck");


/*
class MutantEvent extends Event {
	int type;
}
*/

fun void intro_gain(Gain gain_control, int duration) {
	for(0 => int i; i < duration; i++) {
		((duration - i $ float) + (duration / 2)) / duration => gain_control.gain;
		800::ms => now;
		<<< "note ", i >>>;
	}
}

fun void intro(Gain gain_control, int duration)
{
	//Define primary flute
	Flute flute => PoleZero f => JCRev r => gain_control => dac;
	.75 => r.gain;
	.15 => r.mix;
	.99 => f.blockZero;

	flute.clear( 1.0 );
	0.000005 => flute.jetDelay;
	0.510000 => flute.jetReflection;
	0.000000 => flute.endReflection;
	0.000000 => flute.noiseGain;
	0.400000 => flute.vibratoFreq;
	0.100000 => flute.vibratoGain;
	0.700000 => flute.pressure;

	//Helper variables for play loop
	Event main;

	0 => int cur_note;
	2 => int mutation_type;

	// Main time-loop
	for(0 => int melodic_index; melodic_index < duration; melodic_index++) 
	{
		// print
		<<< "---", "" >>>;
		
		for(0 => int i; i < melody[melodic_index%melody.cap()].cap(); i++) {
			<<< melody[melodic_index%melody.cap()][i], melodic_index, i%melody.cap(), "" >>>;
			if(melody[melodic_index%melody.cap()][i] != cur_note) {
				melody[melodic_index%melody.cap()][i] => cur_note;
				 
				Std.mtof( 12 + cur_note ) => flute.freq; 
				0.75 => flute.noteOn;
			}
			200::ms => now;
		}
		intro_mutate(melody[melodic_index % melody.cap()], mutation_type);
		if(melodic_index > 25 && mutation_type == 2) { 1 => mutation_type; }
		if(melodic_index > 50 && mutation_type == 1) { 3 => mutation_type; }
	}
}

fun void set_melody(int melody[][]) {
	for(0 => int i; i<melody.cap(); i++) {
		basic_scale[i%basic_scale.cap()] => melody[i][0];
		for(1 => int j; j<melody[0].cap(); j++) {
			melody[i][0] => melody[i][j];
		}
	}
}

fun void array_copy(int from[], int to[]) {
	for (0 => int i; i < from.cap(); i++) {
		from[i] => to[i];
	}
}

fun void intro_mutate(int bar[], int type) {
	
	if(type == 2) {
		basic_scale[Std.rand2(1,basic_scale.cap()-1)] =>  int temp_note;
		
		Std.rand2(-1,bar.cap()-3) => int temp_index;
		chout <= temp_index <= IO.newline();
		for(2 => int i;  i>0; i--) {
			temp_note => bar[temp_index+i];
		}
	} else if(type == 1) {
		basic_scale[Std.rand2(1,basic_scale.cap()-1)] =>  int temp_note;
		
		Std.rand2(0,bar.cap()-1) => int temp_index;
		chout <= temp_index <= IO.newline();
		temp_note => bar[temp_index];
	} else if(type == 3){
		basic_scale[Std.rand2(1,basic_scale.cap()-1)] =>  int temp_note;
		
		Std.rand2(0,bar.cap()-1) => int temp_index;
		chout <= temp_index <= IO.newline();
		temp_note => bar[temp_index];
		
		basic_scale[Std.rand2(1,basic_scale.cap()-1)] => temp_note;
		Std.rand2(0,bar.cap()-1) => temp_index;
		chout <= temp_index <= IO.newline();
		temp_note => bar[temp_index];
	}
}
