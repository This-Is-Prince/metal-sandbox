//
//  Shaders.metal
//  FindingGPU
//
//  Created by Prince on 23/10/25.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_ten(
    device float *inputArray [[ buffer(0) ]],
    device float *outputArray [[ buffer(1) ]],
    uint thread_id [[ thread_position_in_grid ]]
) {
    outputArray[thread_id] = inputArray[thread_id] + 10.0;
}
