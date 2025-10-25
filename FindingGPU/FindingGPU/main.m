//
//  main.m
//  FindingGPU
//
//  Created by Prince on 23/10/25.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        
        if (!device) {
            NSLog(@"Error finding GPU.");
            return EXIT_FAILURE;
        }
        
        NSLog(@"Found GPU: %@.", device.name);

        id <MTLCommandQueue> commandQueue = [device newCommandQueue];
        NSLog(@"Created a command queue.");
        
        float inputData[] = {1.0, 2.0, 3.0, 4.0};
        NSUInteger inputDataLength = sizeof(inputData);
        NSLog(@"Created CPU inputData with %lu bytes.", inputDataLength);
        
        id<MTLBuffer> inputBuffer = [device newBufferWithLength: inputDataLength options:MTLResourceStorageModeShared];
        NSLog(@"Created a shared inputBuffer on the GPU.");
        
        void *inputBufferPointer = [inputBuffer contents];
        memcpy(inputBufferPointer, inputData, inputDataLength);
        NSLog(@"Copied data from CPU to the input shared buffer.");
        
        id<MTLBuffer> outputBuffer = [device newBufferWithLength: inputDataLength options: MTLResourceStorageModeShared];
        NSLog(@"Created a shared resultBuffer on the GPU.");
        
        id<MTLLibrary> defaultLibrary = [device newDefaultLibrary];
        if (!defaultLibrary) {
            NSLog(@"Error: Could not load default library.");
            return EXIT_FAILURE;
        }
        NSLog(@"Loaded default library.");
        
        id<MTLFunction> addTenFunc = [defaultLibrary newFunctionWithName:@"add_ten"];
        if (!addTenFunc) {
            NSLog(@"Error: Could not find 'add_ten' function.");
            return EXIT_FAILURE;
        }
        NSLog(@"Found 'add_ten' function in library.");
        
        NSError *pipelineError = nil;
        id<MTLComputePipelineState> addTenPipeline = [device newComputePipelineStateWithFunction: addTenFunc error: &pipelineError];
        
        if (pipelineError || !addTenPipeline) {
            NSLog(@"Error creating pipeline state: %@", pipelineError);
            return EXIT_FAILURE;
        }
        NSLog(@"Created compute pipeline state (the 'blueprint').");
        
        id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
        NSLog(@"Created a command buffer (job order).");
        
        id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
        NSLog(@"Created a compute command encoder ('pen').");
        
        [computeEncoder setComputePipelineState:addTenPipeline];
        
        [computeEncoder setBuffer: inputBuffer offset: 0 atIndex: 0];
        [computeEncoder setBuffer: outputBuffer offset: 0 atIndex: 1];
        
        MTLSize threadsPerGrid = MTLSizeMake(4, 1, 1);
        MTLSize threadsPerThreadgroup = MTLSizeMake(1, 1, 1);
        
        [computeEncoder dispatchThreads: threadsPerGrid threadsPerThreadgroup: threadsPerThreadgroup];
        
        NSLog(@"Dispatched 4 threads to the GPU!");
        
        [computeEncoder endEncoding];
        
        [commandBuffer commit];
        NSLog(@"Comitted the job to the queue. GPU is running...");
        
        [commandBuffer waitUntilCompleted];
        NSLog(@"GPU has finished the job.");
        
        
        NSLog(@"--- Setup Complete ---");
    }
    return EXIT_SUCCESS;
}
