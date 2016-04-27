#include <ilsched/iloscheduler.h>

ILOSTLBEGIN

	int main(){
	IloEnv env;
	try{
		
		IloModel model(env);

		/**
		8 Activities
		**/
		IloActivity t[8];
		
		
		t[0] = IloActivity(env,0);
		t[1] = IloActivity(env,2);		
		t[2] = IloActivity(env,4);
		t[3] = IloActivity(env,2);
		t[4] = IloActivity(env,8);
		t[5] = IloActivity(env,4);
		t[6] = IloActivity(env,4);
		t[7] = IloActivity(env,0);
		
		
		/**
		before and after
		**/
		model.add(t[1].startsAfter(0));
		
		model.add(t[2].startsAfter(1));
		model.add(t[4].startsAfter(1));
		model.add(t[5].startsAfter(1));
		
		/**
		2 skills
		**/
		IloAltResSet compt1(env);
		IloAltResSet compt2(env);
		
		/**
		7 workers
		**/
		IloUnaryResource s[7];
		
		s[0] = IloUnaryResource(env, "Person1");
		s[1] = IloUnaryResource(env, "Person2");
		s[2] = IloUnaryResource(env, "Person3");
		s[3] = IloUnaryResource(env, "Person4");
		s[4] = IloUnaryResource(env, "Person5");
		s[5] = IloUnaryResource(env, "Person6");
		s[6] = IloUnaryResource(env, "Person7");
		
		
		/**
		workers with their skills
		**/
		compt1.add(s[2]);
		compt1.add(s[3]);
		compt1.add(s[4]);
		compt1.add(s[5]);
		compt1.add(s[6]);
		
		compt2.add(s[0]);
		compt2.add(s[1]);
		compt2.add(s[2]);
		compt2.add(s[4]);

		/**
		constraints
		**/
		IloResourceConstraint rct[8];

		
		rct[2] = t[2].requires(compt1,1);
		
		rct[3] = t[3].requires(compt1,1);
		rct[3] = t[3].requires(compt1,1);
		
		rct[4] = t[4].requires(compt1,1);
		
		rct[5] = t[5].requires(compt1,1);
		rct[5] = t[5].requires(compt1,1);
		rct[5] = t[5].requires(compt1,1);
		
		rct[6] = t[6].requires(compt1,1);
		
		
		
		rct[1] = t[1].requires(compt2,1);
		rct[1] = t[1].requires(compt2,1);
		rct[1] = t[1].requires(compt2,1);
		
		rct[2] = t[2].requires(compt2,1);
		rct[2] = t[2].requires(compt2,1);
		
		
		
		for(IloInt i = 0;i<8;i++){
			model.add(rct[i]);
		}

		



		//la fin total
		IloExpr fin(env);
		for (IloInt i =0 ; i<8;i++)
			fin = IloMax(fin,t[i].getEndExpr());

		//fonction objective
		IloObjective obj = IloMinimize(env, fin);
		model.add( obj );

		IloSolver solver(model);

		IloGoal g = IloAssignAlternative(env)&& IloSetTimesForward(env) ;

		if(solver.solve(g)){
			IlcScheduler sched(solver);
			for(IloInt i =0 ; i<10;i++)
				solver.out() << sched.getActivity(t[i]) << " est traite par " << sched.getAltResConstraint(rct[i]).getSelected() <<  endl;
			solver.out() << solver.getValue(fin)<<endl;
			
		}
		
	}
	catch(IloException& e){
		cout << e;
	}
	env.end();
	return 0;
}
