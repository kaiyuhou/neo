#define rand	pan_rand
#define pthread_equal(a,b)	((a)==(b))
#if defined(HAS_CODE) && defined(VERBOSE)
	#ifdef BFS_PAR
		bfs_printf("Pr: %d Tr: %d\n", II, t->forw);
	#else
		cpu_printf("Pr: %d Tr: %d\n", II, t->forw);
	#endif
#endif
	switch (t->forw) {
	default: Uerror("bad forward move");
	case 0:	/* if without executable clauses */
		continue;
	case 1: /* generic 'goto' or 'skip' */
		IfNotBlocked
		_m = 3; goto P999;
	case 2: /* generic 'else' */
		IfNotBlocked
		if (trpt->o_pm&1) continue;
		_m = 3; goto P999;

		 /* PROC :init: */
	case 3: // STATE 1 - /root/neo-kaiyu/src/network.pml:72 - [{c_code2}] (0:0:0 - 1)
		IfNotBlocked
		reached[0][1] = 1;
		/* c_code2 */
		{ 
		sv_save();
        initialize(&now);
     }

#if defined(C_States) && (HAS_TRACK==1)
		c_update((uchar *) &(now.c_state[0]));
#endif
;
		_m = 3; goto P999; /* 0 */
	case 4: // STATE 2 - /root/neo-kaiyu/src/network.pml:77 - [((choice_count>0))] (0:0:0 - 1)
		IfNotBlocked
		reached[0][2] = 1;
		if (!((now.choice_count>0)))
			continue;
		_m = 3; goto P999; /* 0 */
	case 5: // STATE 3 - /root/neo-kaiyu/src/network.pml:78 - [choice = 0] (0:0:1 - 1)
		IfNotBlocked
		reached[0][3] = 1;
		(trpt+1)->bup.oval = now.choice;
		now.choice = 0;
#ifdef VAR_RANGES
		logval("choice", now.choice);
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 6: // STATE 4 - /root/neo-kaiyu/src/network.pml:78 - [((choice<(choice_count-1)))] (0:0:0 - 1)
		IfNotBlocked
		reached[0][4] = 1;
		if (!((now.choice<(now.choice_count-1))))
			continue;
		_m = 3; goto P999; /* 0 */
	case 7: // STATE 5 - /root/neo-kaiyu/src/network.pml:78 - [choice = (choice+1)] (0:0:1 - 1)
		IfNotBlocked
		reached[0][5] = 1;
		(trpt+1)->bup.oval = now.choice;
		now.choice = (now.choice+1);
#ifdef VAR_RANGES
		logval("choice", now.choice);
#endif
		;
		_m = 3; goto P999; /* 0 */
	case 8: // STATE 10 - /root/neo-kaiyu/src/network.pml:79 - [{c_code3}] (0:0:0 - 2)
		IfNotBlocked
		reached[0][10] = 1;
		/* c_code3 */
		{ 
		sv_save();
            exec_step(&now);
         }

#if defined(C_States) && (HAS_TRACK==1)
		c_update((uchar *) &(now.c_state[0]));
#endif
;
		_m = 3; goto P999; /* 0 */
	case 9: // STATE 16 - /root/neo-kaiyu/src/network.pml:85 - [{c_code4}] (0:0:0 - 3)
		IfNotBlocked
		reached[0][16] = 1;
		/* c_code4 */
		{ 
		sv_save();
        report(&now);
     }

#if defined(C_States) && (HAS_TRACK==1)
		c_update((uchar *) &(now.c_state[0]));
#endif
;
		_m = 3; goto P999; /* 0 */
	case 10: // STATE 17 - /root/neo-kaiyu/src/network.pml:88 - [assert(!(violated))] (0:0:0 - 1)
		IfNotBlocked
		reached[0][17] = 1;
		spin_assert( !(((int)now.violated)), " !(violated)", II, tt, t);
		_m = 3; goto P999; /* 0 */
	case 11: // STATE 18 - /root/neo-kaiyu/src/network.pml:89 - [-end-] (0:0:0 - 1)
		IfNotBlocked
		reached[0][18] = 1;
		if (!delproc(1, II)) continue;
		_m = 3; goto P999; /* 0 */
	case  _T5:	/* np_ */
		if (!((!(trpt->o_pm&4) && !(trpt->tau&128))))
			continue;
		/* else fall through */
	case  _T2:	/* true */
		_m = 3; goto P999;
#undef rand
	}

