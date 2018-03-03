#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instruction.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/GlobalVariable.h"
#include <map>
#include <vector>
#include <iostream>
#include <string>
#include <unistd.h>
#include <fstream>

using namespace llvm;

namespace
{
	struct CountLoadsPass : public ModulePass
	{
		
		static char ID;
		CountLoadsPass() : ModulePass(ID) {}
		static long long instructionCount;
		
		//This function adds a call to main() which calls setupAtExit() in exithandler.c
		//at the end of the program's execution.  Returns true of the module has a main()
		//function, as we add to that main function here.
		virtual bool initialize(Module &theModule)
		{
			
			Function *Main = theModule.getFunction("main");
			
			//If this Module does not have a main, skip this; main() should be in a file
			//linked to this module instead.
			if(Main == NULL)
			{
				//If main is null, then we have not changed anything.
				return false;
			}
			
			
			Type *voidType = Type::getVoidTy(theModule.getContext());
			FunctionType *functionType = FunctionType::get(voidType, voidType);
			Constant *setupAtExitFunc = theModule.getOrInsertFunction("setupAtExit", functionType);
			
			BasicBlock *BB = &Main->front();
			Instruction *I = &BB->front();

			CallInst::Create(setupAtExitFunc, "", I);			

			return true;
		}
		
		//This function is called when a file is passed this optimization.  It calls the
		//function above to register the final print with the main(), if present.  It
		//then iterates through all instructions and has each load call addLoad() in
		//exithandler.c.
		virtual bool runOnModule(Module &theModule)
		{
			std::map<std::string,long long> instMap;
			bool changed = false;
			
			//If we changed something in the initialization function, we changed something
			//in the code.
			changed = initialize(theModule);
			for(auto &theFunction : theModule)
			{
				for(auto &theBlock : theFunction)
				{
					for (Instruction &theInstruction : theBlock)
					{
						changed=true;
						std::string curOpcode(theInstruction.getOpcodeName());
						std::cout << curOpcode << " ";
						long long curCount = instMap[curOpcode]++;
						std::cout << curCount << "\n";
						Type *voidType = Type::getVoidTy(theModule.getContext());
						FunctionType *functionType = FunctionType::get(voidType, voidType);
						Constant *loadCountFunction = theModule.getOrInsertFunction("add_llvm_" + curOpcode, functionType);
						CallInst::Create(loadCountFunction, "", &theInstruction);

						//if(auto* op = dyn_cast<LoadInst>(&theInstruction))
						//{
						//	//We have a load instruction, which means that we are
						//	Type *voidType = Type::getVoidTy(theModule.getContext());
						//	FunctionType *functionType = FunctionType::get(voidType, voidType);
						//	Constant *loadCountFunction = theModule.getOrInsertFunction("addLoad", functionType);
						//	CallInst::Create(loadCountFunction, "", &theInstruction);
						//}
					}
				}
			}

			char cwd[1024];
			getcwd(cwd, sizeof(cwd));
			std::string path(cwd);
			std::cout << path << "\n";
			std::ofstream myfile;
			myfile.open(path + "/exithandler.c");
			std::string helperFile = "#include <stdio.h>\n"
			"#include <stdlib.h>\n";
			
			for(std::map<std::string, long long>::const_iterator i = instMap.begin(), end = instMap.end(); i != end; ++i)
			{
				std::string key = i->first;
				long long value = i->second;
				helperFile += "unsigned long long " + key + "Counter = 0;\n";
			}
			
			helperFile += "void exitfunc()\n"
			"{\n"
			"	";
			helperFile += "	printf(\"PERFORMANCE\\n\");\n	";
			for(std::map<std::string, long long>::const_iterator i = instMap.begin(), end = instMap.end(); i != end; ++i)
			{
				std::string key = i->first;
				long long value = i->second;
				helperFile += "	printf(\"" + key + ": %llu\\n\", " + key + "Counter);\n";
			}
			helperFile += "}\n";
			
			for(std::map<std::string, long long>::const_iterator i = instMap.begin(), end = instMap.end(); i != end; ++i)
			{
				std::string key = i->first;
				long long value = i->second;
				helperFile += "void add_llvm_" + key + "()\n"
				"{\n"
				"	" + key + "Counter++;\n"
				"}\n";
			}
			
			helperFile += "void setupAtExit()\n"
			"{\n"
			"	atexit(exitfunc);\n"
			"}\n";
			myfile << helperFile;
			myfile.close();
			
			return changed;
		}
	};
}

char CountLoadsPass::ID = 0;



static RegisterPass<CountLoadsPass> X("countloads", "CountLoads Pass", false, false);
