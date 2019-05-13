using Test: @test, @testset

@eval Main TRACK_TODOS = true
import Todo

Todo.TodoTask("x (A) 2019-05-09 2003-01-23 this is the description +PROJECT @context:23 tag:is-this-value")


module TodoTest
	using Todo: @todo_str
	
	todo"provide more module contents"
	todo"""
		provide a
		multi-line
		todo string
		"""
	
	function f()
		todo"implement this function"
		todo"""
			test
			multi-line
			in
			this function
			"""
	end
	
	macro m()
		todo"implement this macro"
		return :(todo"test macro generated code")
	end
	
	@generated function g(x)
		todo"implement this generated function with value"
		return :(todo"test generated function code")
	end
end


@testset "@todo" begin
	@test length(Todo.todos()) == 7
	
	expected = 0
	@testset "module" begin
		expected += 2+2  # 2 in module plus 2 macro expansions below (which is expanded before this code executes)
		@test sum(values(Todo.todo_hits())) == expected
	end
	
	@testset "+ macro @todo" begin
		TodoTest.@m()
		expected += 1  # 1 in the expansion of the macro
		@test sum(values(Todo.todo_hits())) == expected
	end
	
	@testset "+ repeat macro @todo" begin
		TodoTest.@m()
		expected += 1  # another 1 in the macro expansion
		@test sum(values(Todo.todo_hits())) == expected
	end
	
	@testset "+ function" begin
		TodoTest.f()
		expected += 2  # 2 in the function
		@test sum(values(Todo.todo_hits())) == expected
	end
	
	@testset "+ repeat function" begin
		TodoTest.f()
		expected += 2  # 2 in the function again
		@test sum(values(Todo.todo_hits())) == expected
	end
	
	@testset "+ generated @todo" begin
		TodoTest.g(1)
		expected += 2  # 1 in generating function, 1 in generated function
		@test sum(values(Todo.todo_hits())) == expected
	end
	
	@testset "+ repeat generated @todo" begin
		TodoTest.g(1.0)
		expected += 2  # 1 in generating function, 1 in generated function
		@test sum(values(Todo.todo_hits())) == expected
	end
end


