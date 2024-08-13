local s,id,o=GetID()
function s.initial_effect(c)
	-- Link Summon procedure
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	Link.AddProcedure(c,s.matfilter1,1,4)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_EXTRA_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(1,0)
	e0:SetOperation(aux.TRUE)
	e0:SetValue(s.extraval)
	c:RegisterEffect(e0)
	-- Restrict Special Summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)

	-- If Link Summoned, make all monsters Zombie-Type
	-- Make all monsters Zombie-Type while on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(RACE_ZOMBIE)
	e2:SetCondition(s.zombifycon)
	c:RegisterEffect(e2)

	-- Special Summon from either GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

function s.matfilter1(c)
	return c:IsRace(RACE_ZOMBIE)
end
function s.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf12) or c:IsRace(RACE_ZOMBIE) and c:GetSequence()<5
end
function s.extraval(chk,summon_type,e,...)
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or sc~=e:GetHandler() then
			return Group.CreateGroup()
		else
			Duel.RegisterFlagEffect(tp,id,0,0,1)
			return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_SZONE,0,nil)
		end
	elseif chk==2 then
		Duel.ResetFlagEffect(e:GetHandlerPlayer(),id)
	end
end

-- Restrict Special Summon from hand to only Zombie-Type monsters
function s.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_HAND)
end

-- Check if Link Summoned
function s.zombifycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- Special Summon from either GY
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end