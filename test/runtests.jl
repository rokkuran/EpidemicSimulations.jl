
my_tests = [
    "sir",
    "sis"
]

for test in my_tests
    test_file = string("$test.jl")
    # @printf " * %s\n" test_file
    println("\n$test_file")
    include(test_file)
end