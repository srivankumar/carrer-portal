import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { jobApi } from '../services/api';

// Query keys for cache management
export const jobKeys = {
  all: ['jobs'] as const,
  active: ['jobs', 'active'] as const,
  allJobs: ['jobs', 'all'] as const,
  detail: (id: string) => ['jobs', 'detail', id] as const,
};

// Hook to get active jobs (for users)
export const useActiveJobs = () => {
  return useQuery({
    queryKey: jobKeys.active,
    queryFn: async () => {
      const data = await jobApi.getActiveJobs();
      return data.jobs;
    },
    // Refetch every 60 seconds for real-time updates
    refetchInterval: 60 * 1000,
  });
};

// Hook to get all jobs (for admins)
export const useAllJobs = () => {
  return useQuery({
    queryKey: jobKeys.allJobs,
    queryFn: async () => {
      const data = await jobApi.getAllJobs();
      return data.jobs;
    },
    // Refetch every 60 seconds for real-time updates
    refetchInterval: 60 * 1000,
  });
};

// Hook to get a single job by ID
export const useJob = (id: string) => {
  return useQuery({
    queryKey: jobKeys.detail(id),
    queryFn: async () => {
      const data = await jobApi.getJobById(id);
      return data.job;
    },
    enabled: !!id,
  });
};

// Hook to create a new job
export const useCreateJob = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: jobApi.createJob,
    onSuccess: () => {
      // Invalidate and refetch job lists
      queryClient.invalidateQueries({ queryKey: jobKeys.all });
    },
  });
};

// Hook to update a job
export const useUpdateJob = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => jobApi.updateJob(id, data),
    onSuccess: (_, variables) => {
      // Invalidate specific job and all lists
      queryClient.invalidateQueries({ queryKey: jobKeys.detail(variables.id) });
      queryClient.invalidateQueries({ queryKey: jobKeys.all });
    },
  });
};

// Hook to end job application
export const useEndJobApplication = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: jobApi.endApplication,
    onSuccess: () => {
      // Invalidate all job queries
      queryClient.invalidateQueries({ queryKey: jobKeys.all });
    },
  });
};

// Hook to delete a job
export const useDeleteJob = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: jobApi.deleteJob,
    onSuccess: () => {
      // Invalidate all job queries
      queryClient.invalidateQueries({ queryKey: jobKeys.all });
    },
  });
};
