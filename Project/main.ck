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
<<< "Beginning Intro: ", "" >>>;
Machine.add("../kb2.ck");
main_gain => dac;
spork ~ intro_gain(main_gain, 60);
intro(melody, main_gain, 60);


//First movement
<<< "First Movement: ", "" >>>;
int right_melody[10][4];
array_copy(melody, right_melody);

Gain left_gain;
1 => left_gain.gain;

Gain right_gain;
1 => right_gain.gain;

main_gain =< dac;
spork ~ first_movement(melody, 1, left_gain, 30);
spork ~ first_movement(right_melody, 2, right_gain, 30);
(200*4*30)::ms => now;


//Second Movement
<<< "Second Movement: ", "" >>>;
spork ~ first_gain(left_gain, 60);
spork ~ first_gain(right_gain, 60);
spork ~ first_movement(melody, 1, left_gain, 60);
spork ~ first_movement(right_melody, 2, right_gain, 60);

Gain oleft_gain;
1 => oleft_gain.gain;

Gain oright_gain;
1 => oright_gain.gain;

spork ~ second_gain(oleft_gain, 60);
spork ~ second_gain(oright_gain, 60);
spork ~ second_movement(melody, 1, oleft_gain, 100);
spork ~ second_movement(right_melody, 2, oright_gain, 100);
(200*4*60)::ms => now;



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

fun void first_gain(Gain gain_control, int duration) {
	for(0 => int i; i < duration; i++) {
		(duration - i $ float) / duration => gain_control.gain;
		800::ms => now;
		<<< "note ", i >>>;
	}
}

fun void second_gain(Gain gain_control, int duration) {
	for(duration => int i; i > duration; i--) {
		(duration - i $ float) / duration => gain_control.gain;
		800::ms => now;
		<<< "note ", i >>>;
	}
}

fun void intro(int melody[][], Gain gain_control, int duration)
{
	//Define primary flute
	Flute flute => PoleZero f => JCRev r => gain_control;
	.50 => r.gain;
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
	flute =< f =< r =< gain_control;
}

fun void first_movement(int melody[][], int case, Gain main_gain, int duration)
{
	Flute flute => PoleZero f => JCRev r => main_gain;
	//Define primary flute
	if (case == 1) {
		main_gain => dac.left;
	} else {
		main_gain => dac.right;
	}
	
	.50 => r.gain;
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
	1 => int mutation_type;

	// Main time-loop
	for(0 => int melodic_index; melodic_index < duration; melodic_index++) 
	{
		// print
		<<< "---", case, "" >>>;
		
		for(0 => int i; i < melody[melodic_index%melody.cap()].cap(); i++) {
			<<< melody[melodic_index%melody.cap()][i], melodic_index, i%melody.cap(), case, "" >>>;
			if(melody[melodic_index%melody.cap()][i] != cur_note) {
				melody[melodic_index%melody.cap()][i] => cur_note;
				 
				Std.mtof( 12 + cur_note ) => flute.freq; 
				0.75 => flute.noteOn;
			}
			200::ms => now;
		}
		intro_mutate(melody[melodic_index % melody.cap()], mutation_type);
	}
	if (case == 1) {
		flute =< f =< r =< main_gain =< dac.left;
	} else {
		flute =< f =< r =< main_gain =< dac.right;
	}
}

fun void second_movement(int melody[][], int case, Gain main_gain, int duration)
{
	VoicForm voc=> JCRev r => Echo a => Echo b => Echo c => main_gain;

	if (case == 1) {
		main_gain => dac.left;
	} else {
		main_gain => dac.right;
	}

	// settings
	220.0 => voc.freq;
	0.95 => voc.gain;
	.8 => r.gain;
	.2 => r.mix;
	1000::ms => a.max => b.max => c.max;
	750::ms => a.delay => b.delay => c.delay;
	.50 => a.mix => b.mix => c.mix;

	//Helper variables for play loop
	Event main;

	0 => int cur_note;
	1 => int mutation_type;

	// Main time-loop
	for(0 => int melodic_index; melodic_index < duration; melodic_index++) 
	{
		// print
		<<< "---", case, "" >>>;
		
		for(0 => int i; i < melody[melodic_index%melody.cap()].cap(); i++) {
			<<< melody[melodic_index%melody.cap()][i], melodic_index, i%melody.cap(), case, "" >>>;
			if(melody[melodic_index%melody.cap()][i] != cur_note) {
				melody[melodic_index%melody.cap()][i] => cur_note;
				 
				2*Std.rand2( 0,2 ) => voc.phonemeNum;
				Std.mtof( 12 + cur_note ) => voc.freq; 
				0.75 => voc.noteOn;
			}
			200::ms => now;
		}
	}

	voc=< r =< a =< b =< c =< main_gain;
	if (case == 1) {
		main_gain =< dac.left;
	} else {
		main_gain =< dac.right;
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

fun void array_copy(int from[][], int to[][]) {
	for (0 => int i; i < from.cap(); i++) {
		for (0 => int j; j < from[i].cap(); j++) {
			from[i][j] => to[i][j];
		}
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

