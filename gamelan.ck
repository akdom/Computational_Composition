//Define primary flute
Flute flute=> PoleZero f => JCRev r => dac;
.75 => r.gain;
.15 => r.mix;
.99 => f.blockZero;

flute.clear( 1.0 );
0.000005 => flute.jetDelay;
0.500000 => flute.jetReflection;
0.000000 => flute.endReflection;
0.000000 => flute.noiseGain;
0.400000 => flute.vibratoFreq;
0.100000 => flute.vibratoGain;
0.700000 => flute.pressure;



//Build base melodic info

int melody[10][4];

// Scales
[ 57, 59, 60, 62, 64, 65, 67, 69 ] @=> int a_minor_dia[];

a_minor_dia @=> int basic_scale[];

// Initialize melodic line.
set_melody(melody);




//Helper variables for play loop
0 => int melodic_index;
0 => int cur_note;
[2] @=> int mut_interval[];
Event mutation;
Event main;

spork ~ mutation_shred( mutation, mut_interval );

// Main time-loop
while( true )
{
    // print
    <<< "---", "" >>>;
	
	for(0 => int i; i < melody[melodic_index%melody.cap()].cap(); i++) {
		<<< melody[melodic_index%melody.cap()][i], melodic_index, i%melody.cap(), "" >>>;
		if(melody[melodic_index%melody.cap()][i] != cur_note) {
			melody[melodic_index%melody.cap()][i] => cur_note;
			play( 12 + cur_note, 0.75);
		}
		200::ms => now;
	}
	mutation.broadcast();
	main => now;
	melodic_index++;
	if(melodic_index > 100 && mut_interval[0] == 2) { 1 => mut_interval[0]; }
}

// basic play function (add more arguments as needed)
fun void play( float note, float velocity)
{
    // start the note
	
	Std.mtof( note ) => flute.freq; 
    velocity => flute.noteOn;
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

fun void mutate(int bar[], int interval) {
	basic_scale[Std.rand2(1,basic_scale.cap()-1)] =>  int temp_note;
	
	if(interval == 2) {
		Std.rand2(-1,bar.cap()-3) => int temp_index;
		for(2 => int i;  i>0; i--) {
			temp_note => bar[temp_index+i];
		}
	} else {
		Std.rand2(0,bar.cap()-1) => int temp_index;
		temp_note => bar[temp_index];
	}
}

fun void mutation_shred(Event event, int interval[]) {
	while (true) {
		event => now;
		mutate(melody[melodic_index % melody.cap()], interval[0]);
		main.signal();
	}
}
