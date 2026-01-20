import { supabase } from '../utils/supabase.js';

export const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.split(' ')[1];

    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    let { data: userData, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('id', user.id)
      .maybeSingle();

    // Auto-create user if not found in database
    if (!userData) {
      console.log('⚠️ User not found in database, creating entry for:', user.id);
      const { data: newUser, error: createError } = await supabase
        .from('users')
        .upsert({
          id: user.id,
          email: user.email,
          name: user.user_metadata?.name || user.email?.split('@')[0] || 'User',
          role: 'user',
        })
        .select()
        .single();

      if (createError) {
        console.error('❌ Failed to create user:', createError);
        return res.status(500).json({ error: 'Failed to create user profile' });
      }

      userData = newUser;
      console.log('✅ User profile created successfully');
    }

    if (userError && userError.code !== 'PGRST116') {
      console.error('User lookup error:', userError);
      return res.status(404).json({ error: 'User not found', details: userError.message });
    }

    req.user = userData;
    req.token = token;
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    res.status(500).json({ error: 'Authentication failed' });
  }
};

export const isAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};
