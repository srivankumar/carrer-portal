import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { applicationApi } from '../services/api';

// Query keys for cache management
export const applicationKeys = {
  all: ['applications'] as const,
  myApplications: ['applications', 'my'] as const,
  allApplications: (jobId?: string, status?: string, minScore?: number) => 
    ['applications', 'all', { jobId, status, minScore }] as const,
  topCandidates: (limit?: number) => ['applications', 'top-candidates', limit] as const,
  status: (jobId: string) => ['applications', 'status', jobId] as const,
};

// Hook to get user's applications
export const useMyApplications = () => {
  return useQuery({
    queryKey: applicationKeys.myApplications,
    queryFn: async () => {
      const data = await applicationApi.getMyApplications();
      return data.applications;
    },
    // Refetch every 60 seconds for real-time updates
    refetchInterval: 60 * 1000,
  });
};

// Hook to get all applications (for admins)
export const useAllApplications = (jobId?: string, status?: string, minScore?: number) => {
  return useQuery({
    queryKey: applicationKeys.allApplications(jobId, status, minScore),
    queryFn: async () => {
      const data = await applicationApi.getAllApplications({ jobId, status, minScore });
      return data.applications;
    },
    // Refetch every 60 seconds for real-time updates
    refetchInterval: 60 * 1000,
  });
};

// Hook to get top candidates
export const useTopCandidates = (limit?: number) => {
  return useQuery({
    queryKey: applicationKeys.topCandidates(limit),
    queryFn: async () => {
      const data = await applicationApi.getTopCandidates(limit);
      return data.candidates;
    },
    // Refetch every 60 seconds for real-time updates
    refetchInterval: 60 * 1000,
  });
};

// Hook to check application status
export const useApplicationStatus = (jobId: string) => {
  return useQuery({
    queryKey: applicationKeys.status(jobId),
    queryFn: async () => {
      const data = await applicationApi.checkApplicationStatus(jobId);
      return data;
    },
    enabled: !!jobId,
  });
};

// Hook to apply for a job
export const useApplyForJob = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ jobId, resumeFile }: { jobId: string; resumeFile: File }) => 
      applicationApi.apply(jobId, resumeFile),
    onSuccess: () => {
      // Invalidate applications cache
      queryClient.invalidateQueries({ queryKey: applicationKeys.all });
    },
  });
};

// Hook to update application status
export const useUpdateApplicationStatus = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) => 
      applicationApi.updateStatus(id, status),
    onSuccess: () => {
      // Invalidate all application queries
      queryClient.invalidateQueries({ queryKey: applicationKeys.all });
    },
  });
};

// Hook to bulk update application status
export const useBulkUpdateApplicationStatus = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (updates: Array<{ id: string; status: string }>) => {
      // Execute all updates in parallel
      const results = await Promise.all(
        updates.map(({ id, status }) => applicationApi.updateStatus(id, status))
      );
      return results;
    },
    onSuccess: () => {
      // Invalidate all application queries
      queryClient.invalidateQueries({ queryKey: applicationKeys.all });
    },
  });
};
